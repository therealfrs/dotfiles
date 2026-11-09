--- A Neovim Lua module to open VCS-aware code review diffs with codediff.nvim
--- across colocated jj+git repos, pure jj / jj-on-piper repos, and plain git repos.
local M = {}

local uv = vim.uv or vim.loop

local temp_cleanup_registered = false
---@type string[]
local pending_dirs = {}
---@type table<number, string>
local dirs_by_tab = {}

--- Runs a command synchronously and returns normalized exit status and output.
---@param cmd string[]
---@param cwd? string
---@return { code: number, stdout: string, stderr: string }
local function default_runner(cmd, cwd)
  local res = vim.system(cmd, { text = true, cwd = cwd }):wait()
  return {
    code = res.code or 1,
    stdout = vim.trim(res.stdout or ''),
    stderr = vim.trim(res.stderr or ''),
  }
end

--- Checks whether a string looks like a non-filesystem URI (e.g., jj://, term://).
---@param path string
---@return boolean
local function has_uri_scheme(path)
  return path:match('^[%a][%w+.-]*://') ~= nil
end

--- Deletes any loaded buffers inside dir_path and removes dir_path recursively.
---@param dir_path? string
local function cleanup_dir(dir_path)
  if not dir_path or dir_path == '' then
    return
  end

  local prefix = dir_path .. '/'
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name:sub(1, #prefix) == prefix then
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      end
    end
  end

  vim.fn.delete(dir_path, 'rf')
end

--- Registers autocmds to clean up temporary jj snapshot directories on close/exit.
local function register_cleanup_hooks()
  if temp_cleanup_registered then
    return
  end
  temp_cleanup_registered = true

  local group = vim.api.nvim_create_augroup('CodeDiffJJTempCleanup', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeDiffOpen',
    callback = function(args)
      local dir = table.remove(pending_dirs, 1)
      if not dir then
        return
      end
      local tabpage = (args.data and args.data.tabpage) or vim.api.nvim_get_current_tabpage()
      dirs_by_tab[tabpage] = dir
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeDiffClose',
    callback = function(args)
      local tabpage = (args.data and args.data.tabpage) or vim.api.nvim_get_current_tabpage()
      local dir = dirs_by_tab[tabpage]
      if dir then
        dirs_by_tab[tabpage] = nil
        vim.schedule(function()
          cleanup_dir(dir)
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      for _, dir in pairs(dirs_by_tab) do
        cleanup_dir(dir)
      end
      for _, dir in ipairs(pending_dirs) do
        cleanup_dir(dir)
      end
      dirs_by_tab = {}
      pending_dirs = {}
    end,
  })
end

--- Ensures an empty placeholder file exists at file_path (used for added/deleted diffs).
---@param file_path string
local function ensure_empty_file(file_path)
  vim.fn.mkdir(vim.fs.dirname(file_path), 'p')
  local fh = assert(io.open(file_path, 'w'))
  fh:close()
end

--- Resolves the starting directory for VCS detection.
---@param start_path? string
---@return string
local function resolve_start_path(start_path)
  if start_path and start_path ~= '' then
    local st = uv.fs_stat(start_path)
    if st and st.type ~= 'directory' then
      return vim.fs.dirname(start_path)
    end
    return start_path
  end

  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name ~= '' and not has_uri_scheme(buf_name) then
    local st = uv.fs_stat(buf_name)
    if st then
      return st.type == 'directory' and buf_name or vim.fs.dirname(buf_name)
    end
  end

  return vim.fn.getcwd()
end

--- Detects whether start_path (or current buffer/cwd) is inside a colocated jj+git,
--- pure jj, or plain git repository.
---@param start_path? string
---@return { kind: 'jj_git'|'jj'|'git'|'none', root: string|nil, jj_root?: string, git_root?: string }
function M.detect_vcs(start_path)
  local search_from = resolve_start_path(start_path)

  local jj_marker = vim.fs.find('.jj', { upward = true, path = search_from, type = 'directory' })[1]
  local jj_root = nil
  if jj_marker then
    local st = uv.fs_stat(jj_marker)
    if st and st.type == 'directory' then
      jj_root = vim.fs.normalize(vim.fs.dirname(jj_marker))
    end
  end

  local git_marker = vim.fs.find('.git', { upward = true, path = search_from })[1]
  local git_root = nil
  if git_marker and uv.fs_stat(git_marker) ~= nil then
    git_root = vim.fs.normalize(vim.fs.dirname(git_marker))
  end

  if jj_root and git_root then
    if jj_root == git_root then
      return { kind = 'jj_git', root = jj_root, jj_root = jj_root, git_root = git_root }
    elseif #jj_root > #git_root then
      return { kind = 'jj', root = jj_root, jj_root = jj_root }
    else
      return { kind = 'git', root = git_root, git_root = git_root }
    end
  elseif jj_root then
    return { kind = 'jj', root = jj_root, jj_root = jj_root }
  elseif git_root then
    return { kind = 'git', root = git_root, git_root = git_root }
  end

  return { kind = 'none', root = nil }
end

--- Resolves the diff target for the given VCS descriptor and review mode ('change' or 'stack').
---@param vcs { kind: 'jj_git'|'jj'|'git'|'none', root: string|nil, jj_root?: string, git_root?: string }
---@param mode 'change'|'stack'
---@param runner? fun(cmd: string[], cwd?: string): { code: number, stdout: string, stderr: string }
---@return table
function M.resolve_target(vcs, mode, runner)
  if not vcs or vcs.kind == 'none' then
    return { kind = 'error', message = 'Not inside a jj or git repository' }
  end

  local raw_run = runner or default_runner
  local function run(cmd, cwd)
    local res = raw_run(cmd, cwd)
    return {
      code = res.code or 1,
      stdout = vim.trim(res.stdout or ''),
      stderr = vim.trim(res.stderr or ''),
    }
  end

  if vcs.kind == 'jj_git' then
    if mode == 'change' then
      local empty_res = run({ 'jj', 'log', '--no-graph', '-r', '@', '-T', 'if(empty, "true", "false")' }, vcs.jj_root)
      if empty_res.code ~= 0 then
        return {
          kind = 'error',
          message = empty_res.stderr ~= '' and empty_res.stderr or 'Failed to query jj @',
        }
      end

      if empty_res.stdout == 'false' then
        local parent_res = run(
          { 'jj', 'log', '--no-graph', '--limit', '1', '-r', '@-', '-T', 'commit_id' },
          vcs.jj_root
        )
        if parent_res.code ~= 0 or parent_res.stdout == '' then
          return {
            kind = 'error',
            message = parent_res.stderr ~= '' and parent_res.stderr or 'Failed to resolve jj @-',
          }
        end
        return { kind = 'codediff_rev', rev1 = parent_res.stdout, rev2 = nil }
      end

      local parent_res = run(
        { 'jj', 'log', '--no-graph', '--limit', '1', '-r', '@-', '-T', 'commit_id' },
        vcs.jj_root
      )
      local grandparent_res = run(
        { 'jj', 'log', '--no-graph', '--limit', '1', '-r', '@--', '-T', 'commit_id' },
        vcs.jj_root
      )
      if parent_res.code ~= 0 or parent_res.stdout == '' or grandparent_res.code ~= 0 or grandparent_res.stdout == '' then
        return { kind = 'error', message = 'No parent changes to review' }
      end

      return {
        kind = 'codediff_rev',
        rev1 = grandparent_res.stdout,
        rev2 = parent_res.stdout,
        info = '@ is empty; reviewing @-',
      }
    elseif mode == 'stack' then
      local summary_res = run(
        { 'jj', 'diff', '--no-pager', '--from', 'fork_point(@ | trunk())', '--to', '@', '--summary' },
        vcs.jj_root
      )
      if summary_res.code ~= 0 then
        return {
          kind = 'error',
          message = summary_res.stderr ~= '' and summary_res.stderr or 'Failed to resolve trunk() fork point',
        }
      end
      if summary_res.stdout == '' then
        return { kind = 'empty', info = 'No changes between trunk() and @' }
      end

      local fork_res = run(
        { 'jj', 'log', '--no-graph', '--limit', '1', '-r', 'fork_point(@ | trunk())', '-T', 'commit_id' },
        vcs.jj_root
      )
      if fork_res.code ~= 0 or fork_res.stdout == '' then
        return {
          kind = 'error',
          message = fork_res.stderr ~= '' and fork_res.stderr or 'Failed to resolve trunk() fork point',
        }
      end

      return { kind = 'codediff_rev', rev1 = fork_res.stdout, rev2 = nil }
    end
  elseif vcs.kind == 'jj' then
    if mode == 'change' then
      local empty_res = run({ 'jj', 'log', '--no-graph', '-r', '@', '-T', 'if(empty, "true", "false")' }, vcs.jj_root)
      if empty_res.code ~= 0 then
        return {
          kind = 'error',
          message = empty_res.stderr ~= '' and empty_res.stderr or 'Failed to query jj @',
        }
      end

      if empty_res.stdout == 'false' then
        return { kind = 'jj_snapshot', rev = '@', live_working = true }
      end

      return {
        kind = 'jj_snapshot',
        rev = '@-',
        live_working = false,
        info = '@ is empty; reviewing @-',
      }
    elseif mode == 'stack' then
      local summary_res = run(
        { 'jj', 'diff', '--no-pager', '--from', 'fork_point(@ | trunk())', '--to', '@', '--summary' },
        vcs.jj_root
      )
      if summary_res.code ~= 0 then
        return {
          kind = 'error',
          message = summary_res.stderr ~= '' and summary_res.stderr or 'Failed to resolve trunk() fork point',
        }
      end
      if summary_res.stdout == '' then
        return { kind = 'empty', info = 'No changes between trunk() and @' }
      end

      return {
        kind = 'jj_snapshot',
        from = 'fork_point(@ | trunk())',
        to = '@',
        live_working = true,
      }
    end
  elseif vcs.kind == 'git' then
    if mode == 'change' then
      local status_res = run({ 'git', 'status', '--porcelain' }, vcs.git_root)
      if status_res.code ~= 0 then
        return {
          kind = 'error',
          message = status_res.stderr ~= '' and status_res.stderr or 'Failed to query git status',
        }
      end
      if status_res.stdout ~= '' then
        return { kind = 'codediff_working' }
      end

      return {
        kind = 'codediff_rev',
        rev1 = 'HEAD~1',
        rev2 = 'HEAD',
        info = 'Working tree clean; reviewing HEAD~1..HEAD',
      }
    elseif mode == 'stack' then
      local base_ref = nil
      local sym_res = run({ 'git', 'symbolic-ref', '--quiet', '--short', 'refs/remotes/origin/HEAD' }, vcs.git_root)
      if sym_res.code == 0 and sym_res.stdout ~= '' then
        base_ref = sym_res.stdout
      else
        for _, candidate in ipairs({ 'origin/main', 'origin/master', 'main' }) do
          local verify_res = run({ 'git', 'rev-parse', '--verify', '--quiet', candidate }, vcs.git_root)
          if verify_res.code == 0 then
            base_ref = candidate
            break
          end
        end
      end

      return { kind = 'codediff_merge_base', base = base_ref or 'HEAD~1' }
    end
  end

  return { kind = 'error', message = 'Unsupported review mode: ' .. tostring(mode) }
end

--- Builds the :CodeDiff Ex command string for git/codediff targets.
---@param target table
---@param scope 'repo'|'file'
---@param vcs? table
---@return string|nil
function M.build_codediff_cmd(target, scope, vcs)
  if not target then
    return nil
  end

  if scope == 'repo' then
    local prefix = 'CodeDiff'
    if vcs and vcs.git_root then
      prefix = prefix .. ' -C ' .. vim.fn.fnameescape(vcs.git_root)
    end

    if target.kind == 'codediff_working' then
      return prefix
    elseif target.kind == 'codediff_rev' then
      return prefix .. ' ' .. target.rev1 .. (target.rev2 and (' ' .. target.rev2) or '')
    elseif target.kind == 'codediff_merge_base' then
      return prefix .. ' ' .. target.base .. '...'
    end
  elseif scope == 'file' then
    if target.kind == 'codediff_working' then
      return 'CodeDiff file HEAD'
    elseif target.kind == 'codediff_rev' then
      return 'CodeDiff file ' .. target.rev1 .. (target.rev2 and (' ' .. target.rev2) or '')
    elseif target.kind == 'codediff_merge_base' then
      return 'CodeDiff file ' .. target.base .. '...'
    end
  end

  return nil
end

--- Materializes a pure-jj diff into temporary snapshots and opens CodeDiff dir/file.
---@param vcs table
---@param target table
---@param scope 'repo'|'file'
---@param file_ctx? { relpath: string, abs_file: string }
local function open_jj_snapshot(vcs, target, scope, file_ctx)
  local tmp_root = vim.fn.tempname()
  vim.fn.mkdir(tmp_root, 'p')

  local args = { 'jj', 'diff', '--no-pager' }
  if target.rev then
    table.insert(args, '-r')
    table.insert(args, target.rev)
  else
    table.insert(args, '--from')
    table.insert(args, target.from)
    table.insert(args, '--to')
    table.insert(args, target.to)
  end

  table.insert(args, '--config=merge-tools.nvim_snap.program="sh"')
  table.insert(
    args,
    '--config=merge-tools.nvim_snap.diff-args=["-c", "cp -RL \\"$1\\" \\"$3/left\\" && cp -RL \\"$2\\" \\"$3/right\\"", "jj-snap", "$left", "$right", '
      .. vim.fn.json_encode(tmp_root)
      .. ']'
  )
  table.insert(args, '--tool=nvim_snap')

  if scope == 'file' and file_ctx then
    table.insert(args, '--')
    table.insert(args, file_ctx.relpath)
  end

  local res = default_runner(args, vcs.jj_root)
  if res.code ~= 0 then
    vim.fn.delete(tmp_root, 'rf')
    vim.notify(res.stderr ~= '' and res.stderr or 'jj diff failed', vim.log.levels.ERROR)
    return
  end

  local left_dir = tmp_root .. '/left'
  local right_dir = tmp_root .. '/right'
  if vim.fn.isdirectory(left_dir) == 0 or vim.fn.isdirectory(right_dir) == 0 then
    vim.fn.delete(tmp_root, 'rf')
    vim.notify('No changes to review', vim.log.levels.INFO)
    return
  end

  local cmd
  if scope == 'repo' then
    if #vim.fn.readdir(left_dir) == 0 and #vim.fn.readdir(right_dir) == 0 then
      vim.fn.delete(tmp_root, 'rf')
      vim.notify('No changes to review', vim.log.levels.INFO)
      return
    end
    cmd = 'CodeDiff dir ' .. vim.fn.fnameescape(left_dir) .. ' ' .. vim.fn.fnameescape(right_dir)
  else
    local snap_left = left_dir .. '/' .. file_ctx.relpath
    local snap_right = right_dir .. '/' .. file_ctx.relpath
    local has_left = uv.fs_stat(snap_left) ~= nil
    local has_right = uv.fs_stat(snap_right) ~= nil

    if not has_left and not has_right then
      vim.fn.delete(tmp_root, 'rf')
      vim.notify('No changes in current file', vim.log.levels.INFO)
      return
    end

    if not has_left then
      ensure_empty_file(snap_left)
    end

    local right_file
    if target.live_working and vim.fn.filereadable(file_ctx.abs_file) == 1 then
      right_file = file_ctx.abs_file
    else
      right_file = snap_right
      if not has_right then
        ensure_empty_file(right_file)
      end
    end

    cmd = 'CodeDiff file ' .. vim.fn.fnameescape(snap_left) .. ' ' .. vim.fn.fnameescape(right_file)
  end

  register_cleanup_hooks()
  table.insert(pending_dirs, tmp_root)

  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    for i = #pending_dirs, 1, -1 do
      if pending_dirs[i] == tmp_root then
        table.remove(pending_dirs, i)
        break
      end
    end
    cleanup_dir(tmp_root)
    vim.notify(tostring(err or 'Failed to open CodeDiff'), vim.log.levels.ERROR)
  end
end

--- Runs a review flow for the given mode ('change' or 'stack') and scope ('repo' or 'file').
---@param mode 'change'|'stack'
---@param scope 'repo'|'file'
---@param file_ctx? { relpath?: string, abs_file: string }
local function run_review(mode, scope, file_ctx)
  local start_path = file_ctx and file_ctx.abs_file or nil
  local vcs = M.detect_vcs(start_path)
  local target = M.resolve_target(vcs, mode)

  if target.kind == 'error' then
    vim.notify(target.message or 'Unable to resolve diff target', vim.log.levels.ERROR)
    return
  end

  if target.info then
    vim.notify(target.info, vim.log.levels.INFO)
  end

  if target.kind == 'empty' then
    return
  end

  if target.kind == 'jj_snapshot' then
    if scope == 'file' and file_ctx then
      local relpath = vim.fs.relpath(vcs.jj_root, file_ctx.abs_file)
      if not relpath or relpath == '' then
        vim.notify('Current file is outside jj repository root', vim.log.levels.ERROR)
        return
      end
      file_ctx.relpath = relpath
    end
    open_jj_snapshot(vcs, target, scope, file_ctx)
    return
  end

  local cmd = M.build_codediff_cmd(target, scope, vcs)
  if not cmd then
    vim.notify('Could not construct CodeDiff command', vim.log.levels.ERROR)
    return
  end
  vim.cmd(cmd)
end

--- Opens CodeDiff for the current change (@ / @- in jj, working tree / HEAD in git).
function M.review_change()
  run_review('change', 'repo')
end

--- Opens CodeDiff for the current buffer's file against the active change base.
function M.review_file()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name == '' or has_uri_scheme(buf_name) or vim.fn.filereadable(buf_name) == 0 then
    vim.notify('Current buffer is not a readable file on disk', vim.log.levels.ERROR)
    return
  end

  local abs_file = vim.fs.normalize(vim.fn.fnamemodify(buf_name, ':p'))
  run_review('change', 'file', { abs_file = abs_file })
end

--- Opens CodeDiff for the cumulative stack against trunk() or the Git default branch.
function M.review_stack()
  run_review('stack', 'repo')
end

--- Registers user commands for VCS-aware CodeDiff reviews.
function M.setup()
  vim.api.nvim_create_user_command('ReviewDiff', function()
    M.review_change()
  end, {
    desc = 'Open CodeDiff for the current change (jj @/@- or git working tree)',
  })

  vim.api.nvim_create_user_command('ReviewFile', function()
    M.review_file()
  end, {
    desc = 'Open CodeDiff for the current file against the active change base',
  })

  vim.api.nvim_create_user_command('ReviewStack', function()
    M.review_stack()
  end, {
    desc = 'Open CodeDiff for the cumulative stack against trunk() or default branch',
  })
end

return M
