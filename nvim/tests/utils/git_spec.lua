local assert = require('luassert')

describe("git utils", function()
  local git
  local tmp_dirs

  before_each(function()
    tmp_dirs = {}
    package.loaded['utils.git'] = nil
    git = require('utils.git')
  end)

  after_each(function()
    pcall(vim.api.nvim_del_user_command, 'GitHunks')
    for _, dir in ipairs(tmp_dirs) do
      vim.fn.delete(dir, 'rf')
    end
  end)

  describe("setup", function()
    it("defines the GitHunks user command", function()
      git.setup()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.GitHunks)
    end)
  end)

  describe("_sort_hunks", function()
    it("sorts hunks with current file first, then by filename and line number", function()
      local items = {
        { filename = "/path/to/b.lua", lnum = 20 },
        { filename = "/path/to/curr.lua", lnum = 50 },
        { filename = "/path/to/a.lua", lnum = 10 },
        { filename = "/path/to/curr.lua", lnum = 15 },
      }

      local sorted = git._sort_hunks(items, 0, "/path/to/curr.lua")
      assert.are.equal(4, #sorted)
      assert.are.equal("/path/to/curr.lua", sorted[1].filename)
      assert.are.equal(15, sorted[1].lnum)
      assert.are.equal("/path/to/curr.lua", sorted[2].filename)
      assert.are.equal(50, sorted[2].lnum)
      assert.are.equal("/path/to/a.lua", sorted[3].filename)
      assert.are.equal(10, sorted[3].lnum)
      assert.are.equal("/path/to/b.lua", sorted[4].filename)
      assert.are.equal(20, sorted[4].lnum)
    end)
  end)

  describe("ensure_files_ref_storage", function()
    local uv = vim.uv or vim.loop

    local function make_temp_root()
      local dir = vim.fn.tempname()
      vim.fn.mkdir(dir, 'p')
      table.insert(tmp_dirs, dir)
      return dir
    end

    local function read_all(path)
      local fh = assert(io.open(path, 'r'))
      local content = fh:read('*a')
      fh:close()
      return content
    end

    it("is a no-op when plugins already use files ref storage", function()
      local lazy_root = make_temp_root()
      vim.fn.mkdir(lazy_root .. '/already_files.nvim/.git', 'p')

      local calls = 0
      local migrated = git.ensure_files_ref_storage(lazy_root, function()
        calls = calls + 1
        return { code = 0, stdout = '', stderr = '' }
      end)

      assert.are.same({}, migrated)
      assert.are.equal(0, calls)
    end)

    it("migrates reftable plugin repos to files ref storage and strips .invalid refspecs", function()
      local lazy_root = make_temp_root()
      local repo = lazy_root .. '/sample.nvim'
      vim.fn.mkdir(repo, 'p')

      local init_res = vim.system(
        { 'git', 'init', '-q', repo },
        { text = true, env = { GIT_DEFAULT_REF_STORAGE_FORMAT = 'reftable' } }
      ):wait()
      assert.are.equal(0, init_res.code)

      local commit_res = vim.system({
        'git', '-C', repo,
        '-c', 'user.name=Test',
        '-c', 'user.email=test@example.com',
        'commit', '--allow-empty', '-q', '-m', 'init',
      }, { text = true }):wait()
      assert.are.equal(0, commit_res.code)

      local cfg_res = vim.system({
        'git', '-C', repo, 'config', '--add', 'remote.origin.fetch',
        '+refs/heads/.invalid:refs/remotes/origin/.invalid',
      }, { text = true }):wait()
      assert.are.equal(0, cfg_res.code)

      assert.is_not_nil(uv.fs_stat(repo .. '/.git/reftable'))

      local migrated = git.ensure_files_ref_storage(lazy_root)
      assert.are.same({ 'sample.nvim' }, migrated)
      assert.is_nil(uv.fs_stat(repo .. '/.git/reftable'))

      local head_line = vim.fn.readfile(repo .. '/.git/HEAD', '', 1)[1] or ''
      assert.is_nil(head_line:match('%.invalid'))
      assert.is_not_nil(head_line:match('^ref: refs/heads/'))

      local git_config = read_all(repo .. '/.git/config')
      assert.is_nil(git_config:match('%.invalid'))
    end)
  end)
end)
