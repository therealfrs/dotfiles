local assert = require('luassert')

describe('codediff utils', function()
  local codediff
  local tmp_dirs

  local function make_dir(path)
    vim.fn.mkdir(path, 'p')
    return path
  end

  local function make_temp_root()
    local dir = vim.fn.tempname()
    make_dir(dir)
    table.insert(tmp_dirs, dir)
    return vim.fs.normalize(dir)
  end

  before_each(function()
    tmp_dirs = {}
    package.loaded['utils.codediff'] = nil
    codediff = require('utils.codediff')
  end)

  after_each(function()
    for _, cmd in ipairs({ 'ReviewDiff', 'ReviewFile', 'ReviewStack' }) do
      pcall(vim.api.nvim_del_user_command, cmd)
    end
    for _, dir in ipairs(tmp_dirs) do
      vim.fn.delete(dir, 'rf')
    end
  end)

  describe('setup', function()
    it('defines ReviewDiff, ReviewFile, and ReviewStack user commands', function()
      codediff.setup()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.ReviewDiff)
      assert.is_not_nil(commands.ReviewFile)
      assert.is_not_nil(commands.ReviewStack)
    end)
  end)

  describe('detect_vcs', function()
    it('detects colocated jj and git repositories', function()
      local root = make_temp_root()
      make_dir(root .. '/.jj')
      make_dir(root .. '/.git')
      local sub = make_dir(root .. '/sub/dir')

      local vcs = codediff.detect_vcs(sub)
      assert.are.equal('jj_git', vcs.kind)
      assert.are.equal(root, vcs.root)
      assert.are.equal(root, vcs.jj_root)
      assert.are.equal(root, vcs.git_root)
    end)

    it('detects pure jj repositories (e.g. jj-on-piper)', function()
      local root = make_temp_root()
      make_dir(root .. '/.jj')
      local sub = make_dir(root .. '/nested/pkg')

      local vcs = codediff.detect_vcs(sub)
      assert.are.equal('jj', vcs.kind)
      assert.are.equal(root, vcs.root)
      assert.are.equal(root, vcs.jj_root)
      assert.is_nil(vcs.git_root)
    end)

    it('detects plain git repositories', function()
      local root = make_temp_root()
      make_dir(root .. '/.git')
      local sub = make_dir(root .. '/src')

      local vcs = codediff.detect_vcs(sub)
      assert.are.equal('git', vcs.kind)
      assert.are.equal(root, vcs.root)
      assert.are.equal(root, vcs.git_root)
      assert.is_nil(vcs.jj_root)
    end)

    it('prefers inner pure jj repo nested inside an outer git repo', function()
      local outer = make_temp_root()
      make_dir(outer .. '/.git')
      local inner = make_dir(outer .. '/inner_jj')
      make_dir(inner .. '/.jj')
      local sub = make_dir(inner .. '/sub')

      local vcs = codediff.detect_vcs(sub)
      assert.are.equal('jj', vcs.kind)
      assert.are.equal(inner, vcs.root)
      assert.are.equal(inner, vcs.jj_root)
    end)

    it('prefers inner git repo nested inside an outer jj repo', function()
      local outer = make_temp_root()
      make_dir(outer .. '/.jj')
      local inner = make_dir(outer .. '/inner_git')
      make_dir(inner .. '/.git')

      local vcs = codediff.detect_vcs(inner)
      assert.are.equal('git', vcs.kind)
      assert.are.equal(inner, vcs.root)
      assert.are.equal(inner, vcs.git_root)
    end)

    it('returns none outside of jj and git repositories', function()
      local dir = make_temp_root()

      local vcs = codediff.detect_vcs(dir)
      assert.are.equal('none', vcs.kind)
      assert.is_nil(vcs.root)
    end)
  end)

  describe('resolve_target and build_codediff_cmd', function()
    local function make_mock_runner(responses)
      return function(cmd)
        local key = table.concat(cmd, ' ')
        local res = responses[key]
        if res then
          return res
        end
        return { code = 1, stdout = '', stderr = 'unexpected command: ' .. key }
      end
    end

    it('resolves jj_git change against @- when @ is non-empty', function()
      local vcs = { kind = 'jj_git', root = '/repo', jj_root = '/repo', git_root = '/repo' }
      local runner = make_mock_runner({
        ['jj log --no-graph -r @ -T if(empty, "true", "false")'] = { code = 0, stdout = 'false', stderr = '' },
        ['jj log --no-graph --limit 1 -r @- -T commit_id'] = { code = 0, stdout = 'abc123parent', stderr = '' },
      })

      local target = codediff.resolve_target(vcs, 'change', runner)
      assert.are.equal('codediff_rev', target.kind)
      assert.are.equal('abc123parent', target.rev1)
      assert.is_nil(target.rev2)
      assert.are.equal('CodeDiff -C /repo abc123parent', codediff.build_codediff_cmd(target, 'repo', vcs))
      assert.are.equal('CodeDiff file abc123parent', codediff.build_codediff_cmd(target, 'file', vcs))
    end)

    it('resolves jj_git change to @--..@- when @ is empty', function()
      local vcs = { kind = 'jj_git', root = '/repo', jj_root = '/repo', git_root = '/repo' }
      local runner = make_mock_runner({
        ['jj log --no-graph -r @ -T if(empty, "true", "false")'] = { code = 0, stdout = 'true', stderr = '' },
        ['jj log --no-graph --limit 1 -r @- -T commit_id'] = { code = 0, stdout = 'parentsha', stderr = '' },
        ['jj log --no-graph --limit 1 -r @-- -T commit_id'] = { code = 0, stdout = 'grandparentsha', stderr = '' },
      })

      local target = codediff.resolve_target(vcs, 'change', runner)
      assert.are.equal('codediff_rev', target.kind)
      assert.are.equal('grandparentsha', target.rev1)
      assert.are.equal('parentsha', target.rev2)
      assert.are.equal('@ is empty; reviewing @-', target.info)
      assert.are.equal(
        'CodeDiff -C /repo grandparentsha parentsha',
        codediff.build_codediff_cmd(target, 'repo', vcs)
      )
      assert.are.equal(
        'CodeDiff file grandparentsha parentsha',
        codediff.build_codediff_cmd(target, 'file', vcs)
      )
    end)

    it('resolves jj_git stack against trunk() fork_point when non-empty and empty otherwise', function()
      local vcs = { kind = 'jj_git', root = '/repo', jj_root = '/repo', git_root = '/repo' }
      local runner_with_changes = make_mock_runner({
        ['jj diff --no-pager --from fork_point(@ | trunk()) --to @ --summary'] = {
          code = 0,
          stdout = 'M src/main.cc',
          stderr = '',
        },
        ['jj log --no-graph --limit 1 -r fork_point(@ | trunk()) -T commit_id'] = {
          code = 0,
          stdout = 'trunkforksha',
          stderr = '',
        },
      })

      local target = codediff.resolve_target(vcs, 'stack', runner_with_changes)
      assert.are.equal('codediff_rev', target.kind)
      assert.are.equal('trunkforksha', target.rev1)
      assert.are.equal('CodeDiff -C /repo trunkforksha', codediff.build_codediff_cmd(target, 'repo', vcs))

      local runner_empty = make_mock_runner({
        ['jj diff --no-pager --from fork_point(@ | trunk()) --to @ --summary'] = {
          code = 0,
          stdout = '',
          stderr = '',
        },
      })
      local empty_target = codediff.resolve_target(vcs, 'stack', runner_empty)
      assert.are.equal('empty', empty_target.kind)
      assert.are.equal('No changes between trunk() and @', empty_target.info)
    end)

    it('resolves pure jj change and stack snapshot targets', function()
      local vcs = { kind = 'jj', root = '/citc/repo', jj_root = '/citc/repo' }

      local non_empty_runner = make_mock_runner({
        ['jj log --no-graph -r @ -T if(empty, "true", "false")'] = { code = 0, stdout = 'false', stderr = '' },
      })
      local non_empty = codediff.resolve_target(vcs, 'change', non_empty_runner)
      assert.are.equal('jj_snapshot', non_empty.kind)
      assert.are.equal('@', non_empty.rev)
      assert.is_true(non_empty.live_working)

      local empty_runner = make_mock_runner({
        ['jj log --no-graph -r @ -T if(empty, "true", "false")'] = { code = 0, stdout = 'true', stderr = '' },
      })
      local empty_wc = codediff.resolve_target(vcs, 'change', empty_runner)
      assert.are.equal('jj_snapshot', empty_wc.kind)
      assert.are.equal('@-', empty_wc.rev)
      assert.is_false(empty_wc.live_working)
      assert.are.equal('@ is empty; reviewing @-', empty_wc.info)

      local stack_runner = make_mock_runner({
        ['jj diff --no-pager --from fork_point(@ | trunk()) --to @ --summary'] = {
          code = 0,
          stdout = 'A foo.cc',
          stderr = '',
        },
      })
      local stack_target = codediff.resolve_target(vcs, 'stack', stack_runner)
      assert.are.equal('jj_snapshot', stack_target.kind)
      assert.are.equal('fork_point(@ | trunk())', stack_target.from)
      assert.are.equal('@', stack_target.to)
      assert.is_true(stack_target.live_working)

      local empty_stack_runner = make_mock_runner({
        ['jj diff --no-pager --from fork_point(@ | trunk()) --to @ --summary'] = {
          code = 0,
          stdout = '',
          stderr = '',
        },
      })
      local empty_stack = codediff.resolve_target(vcs, 'stack', empty_stack_runner)
      assert.are.equal('empty', empty_stack.kind)
    end)

    it('resolves git dirty working tree, clean working tree, and stack merge-base', function()
      local vcs = { kind = 'git', root = '/gitrepo', git_root = '/gitrepo' }

      local dirty_runner = make_mock_runner({
        ['git status --porcelain'] = { code = 0, stdout = ' M init.lua', stderr = '' },
      })
      local dirty = codediff.resolve_target(vcs, 'change', dirty_runner)
      assert.are.equal('codediff_working', dirty.kind)
      assert.are.equal('CodeDiff -C /gitrepo', codediff.build_codediff_cmd(dirty, 'repo', vcs))
      assert.are.equal('CodeDiff file HEAD', codediff.build_codediff_cmd(dirty, 'file', vcs))

      local clean_runner = make_mock_runner({
        ['git status --porcelain'] = { code = 0, stdout = '', stderr = '' },
      })
      local clean = codediff.resolve_target(vcs, 'change', clean_runner)
      assert.are.equal('codediff_rev', clean.kind)
      assert.are.equal('HEAD~1', clean.rev1)
      assert.are.equal('HEAD', clean.rev2)
      assert.are.equal('Working tree clean; reviewing HEAD~1..HEAD', clean.info)
      assert.are.equal('CodeDiff -C /gitrepo HEAD~1 HEAD', codediff.build_codediff_cmd(clean, 'repo', vcs))
      assert.are.equal('CodeDiff file HEAD~1 HEAD', codediff.build_codediff_cmd(clean, 'file', vcs))

      local stack_runner = make_mock_runner({
        ['git symbolic-ref --quiet --short refs/remotes/origin/HEAD'] = { code = 1, stdout = '', stderr = '' },
        ['git rev-parse --verify --quiet origin/main'] = { code = 0, stdout = 'deadbeef', stderr = '' },
      })
      local stack = codediff.resolve_target(vcs, 'stack', stack_runner)
      assert.are.equal('codediff_merge_base', stack.kind)
      assert.are.equal('origin/main', stack.base)
      assert.are.equal('CodeDiff -C /gitrepo origin/main...', codediff.build_codediff_cmd(stack, 'repo', vcs))
      assert.are.equal('CodeDiff file origin/main...', codediff.build_codediff_cmd(stack, 'file', vcs))
    end)
  end)
end)
