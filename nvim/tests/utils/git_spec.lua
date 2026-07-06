local assert = require('luassert')

describe("git utils", function()
  local git

  before_each(function()
    package.loaded['utils.git'] = nil
    git = require('utils.git')
  end)

  after_each(function()
    pcall(vim.api.nvim_del_user_command, 'GitHunks')
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
end)
