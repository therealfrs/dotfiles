--- A Neovim Lua module to run Ninja builds in a subdirectory
-- and automatically fix the paths in the quickfix list.
local M = {}

local build_dir = nil

local function fix_qf_paths()
  if not build_dir then
    return
  end

  local qf_list = vim.fn.getqflist()
  if vim.tbl_isempty(qf_list) then
    vim.notify("Build successful!", vim.log.levels.INFO)
    build_dir = nil
    return
  end

  local new_qf_list = {}

  for _, item in ipairs(qf_list) do
    local new_item = vim.deepcopy(item)
    local filename = new_item.filename
    if (not filename or filename == "") and new_item.bufnr and new_item.bufnr > 0 then
      filename = vim.fn.bufname(new_item.bufnr)
    end

    if filename and filename ~= "" then
      local final_filename
      if filename:sub(1, 1) == '/' then
        final_filename = filename
      else
        final_filename = build_dir .. '/' .. filename
      end
      new_item.filename = vim.fn.simplify(final_filename)
      new_item.bufnr = 0 -- Unset bufnr to force use of filename
    end
    table.insert(new_qf_list, new_item)
  end

  vim.fn.setqflist(new_qf_list, 'r')
  vim.notify("Quickfix paths adjusted for build directory: " .. build_dir, vim.log.levels.INFO)

  -- IMPORTANT: Reset the build_dir to nil.
  -- This prevents this function from incorrectly modifying the quickfix list
  -- for other commands (e.g., a manual :make or :grep).
  build_dir = nil

  -- Jump to first problem.
  vim.cmd("cnext")
end

function M.build(args)
  if not args or #args < 1 then
    vim.notify("Usage: NinjaBuild <path> [target]", vim.log.levels.ERROR)
    return
  end

  local path = args[1]
  local target = args[2] or "all"

  build_dir = path

  vim.o.makeprg = string.format("autoninja -C %s %s", vim.fn.fnameescape(path), vim.fn.fnameescape(target))
  vim.notify("Running build: " .. vim.o.makeprg)

  vim.cmd("make!")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("NinjaBuildQuickfix", { clear = true })

  vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    group = group,
    callback = fix_qf_paths,
  })

  -- Create the :NinjaBuild user command.
  vim.api.nvim_create_user_command(
    'NinjaBuild',
    function(opts)
      M.build(opts.fargs)
    end,
    {
      nargs = '+',
      complete = 'dir', -- Provides directory completion for the first argument.
      desc = 'Build with Ninja in a specific directory. Usage: :NinjaBuild <path> [target]',
    }
  )
  vim.notify("NinjaBuild command and helpers setup complete.", vim.log.levels.INFO)
end

return M
