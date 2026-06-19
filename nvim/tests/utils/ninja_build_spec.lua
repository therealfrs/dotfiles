local assert = require('luassert')

describe("ninja_build", function()
  local ninja_build

  before_each(function()
    -- Clear package cache to ensure a fresh load of the module if needed,
    -- but usually just requiring it is fine if we don't mutate module-level state
    -- in a way that carries over.
    -- However, ninja_build has package-level local `build_dir`.
    -- To reset it completely, we can unload the module.
    package.loaded['utils.ninja_build'] = nil
    ninja_build = require('utils.ninja_build')
    
    -- Setup the plugin (creates commands, autocmds)
    ninja_build.setup()
    
    -- Clear quickfix list
    vim.fn.setqflist({}, 'r')
  end)

  after_each(function()
    -- Clean up user commands and autocommands to avoid pollution
    pcall(vim.api.nvim_del_user_command, 'NinjaBuild')
    -- Autocommands are in a group, we can clear the group
    local group_id = vim.api.nvim_create_augroup("NinjaBuildQuickfix", { clear = true })
    vim.api.nvim_del_augroup_by_id(group_id)
  end)

  describe("setup", function()
    it("defines the NinjaBuild user command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.NinjaBuild)
    end)
  end)

  describe("build", function()
    it("sets makeprg correctly and calls make", function()
      -- Mock vim.cmd to prevent actual 'make!' execution
      local cmd_calls = {}
      local original_cmd = vim.cmd
      vim.cmd = function(cmd)
        table.insert(cmd_calls, cmd)
      end

      ninja_build.build({"out/Debug", "all"})

      -- Restore vim.cmd immediately
      vim.cmd = original_cmd

      assert.are.equal("autoninja -C out/Debug all", vim.o.makeprg)
      assert.are.equal(1, #cmd_calls)
      assert.are.equal("make!", cmd_calls[1])
    end)

    it("notifies and returns if no arguments are provided", function()
      local notify_calls = {}
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        table.insert(notify_calls, {msg = msg, level = level})
      end

      ninja_build.build({})

      vim.notify = original_notify

      assert.are.equal(1, #notify_calls)
      assert.are.equal("Usage: NinjaBuild <path> [target]", notify_calls[1].msg)
      assert.are.equal(vim.log.levels.ERROR, notify_calls[1].level)
    end)
  end)

  describe("quickfix path adjustment (integration)", function()
    it("adjusts relative paths and leaves absolute paths alone", function()
      -- 1. Simulate running build to set the build_dir internally.
      -- We mock vim.cmd to avoid running the real make.
      local original_cmd = vim.cmd
      vim.cmd = function() end
      ninja_build.build({"my_build_dir"})
      vim.cmd = original_cmd

      -- 2. Populate the quickfix list with a mix of relative and absolute paths.
      -- We use dummy buffer numbers or filenames.
      local initial_qf = {
        { filename = "src/main.cc", lnum = 10, text = "error 1", valid = 1 },
        { filename = "/absolute/path/to/header.h", lnum = 20, text = "error 2", valid = 1 },
      }
      vim.fn.setqflist(initial_qf, 'r')

      -- We also need to mock vim.cmd again because QuickFixCmdPost might call "cfirst"
      -- which might fail if the quickfix list doesn't actually have valid buffers/files
      -- that exist on disk, or it might just work. Let's mock it to be safe and just assert
      -- it tries to run "cfirst".
      local cmd_calls = {}
      vim.cmd = function(cmd)
        table.insert(cmd_calls, cmd)
      end

      -- 3. Trigger the QuickFixCmdPost autocommand which calls fix_qf_paths
      vim.api.nvim_exec_autocmds("QuickFixCmdPost", {
        group = "NinjaBuildQuickfix",
        pattern = "make",
      })

      vim.cmd = original_cmd

      -- 4. Assertions
      local updated_qf = vim.fn.getqflist()
      assert.are.equal(2, #updated_qf)

      -- Relative path should be prefixed and simplified (simplified might remove redundant slashes,
      -- but here it should just join them).
      -- vim.fn.simplify might resolve it.
      local expected_rel = vim.fn.simplify("my_build_dir/src/main.cc")
      assert.are.equal(expected_rel, vim.fn.bufname(updated_qf[1].bufnr))

      -- Absolute path should remain unchanged
      assert.are.equal("/absolute/path/to/header.h", vim.fn.bufname(updated_qf[2].bufnr))

      -- Helper to check if a table contains a value
      local function has_value(tab, val)
        for _, value in ipairs(tab) do
          if value == val then
            return true
          end
        end
        return false
      end

      -- cfirst should have been called
      assert.is_true(has_value(cmd_calls, "cfirst"))
    end)
  end)
end)
