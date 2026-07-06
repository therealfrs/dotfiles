--- A Neovim Lua module to search and display Git hunks cleanly using Telescope
--- without mutating global quickfix state or leaking global variables.
local M = {}

--- Normalizes a buffer number or filename into an absolute path.
---@param bufnr? number
---@param filename? string
---@return string
local function get_abs_path(bufnr, filename)
  if (not filename or filename == "") and bufnr and bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    filename = vim.api.nvim_buf_get_name(bufnr)
  end
  if filename and filename ~= "" then
    return vim.fn.fnamemodify(filename, ":p")
  end
  return ""
end

--- Sorts hunk items with those in the current buffer/file first,
--- then alphabetically by filename, and finally by line number.
---@param items table[]
---@param curr_buf number
---@param curr_file string
---@return table[]
function M._sort_hunks(items, curr_buf, curr_file)
  -- Enrich items once upfront (Schwartzian transform) to avoid repeated
  -- filesystem and Vim API calls inside the sort comparator.
  for _, item in ipairs(items) do
    local abs_path = get_abs_path(item.bufnr, item.filename)
    item.filename = abs_path
    item._is_current = (item.bufnr == curr_buf) or (abs_path ~= "" and abs_path == curr_file)
  end

  table.sort(items, function(a, b)
    if a._is_current ~= b._is_current then
      return a._is_current
    end
    if a.filename ~= b.filename then
      return (a.filename or "") < (b.filename or "")
    end
    return (a.lnum or 0) < (b.lnum or 0)
  end)

  -- Clean up temporary enrichment properties
  for _, item in ipairs(items) do
    item._is_current = nil
  end

  return items
end

--- Opens a custom Telescope picker for Git hunks.
---@param items table[]
---@param opts? table
local function open_hunks_picker(items, opts)
  local has_telescope, pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    vim.notify("Telescope is not installed or available", vim.log.levels.ERROR)
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Git Hunks (Current File First)",
    finder = finders.new_table({
      results = items,
      entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
    }),
    previewer = conf.qflist_previewer(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

--- Asynchronously fetches all Git hunks across the repository and displays them
--- in a Telescope picker, sorted by current file first.
--- Preserves existing Quickfix list state.
---@param opts? table
function M.search_hunks(opts)
  local has_gitsigns, gitsigns = pcall(require, "gitsigns")
  if not has_gitsigns then
    vim.notify("gitsigns.nvim is not installed or available", vim.log.levels.ERROR)
    return
  end

  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_file = get_abs_path(curr_buf, nil)

  -- Preserve user's existing Quickfix list state so we do not clobber
  -- ongoing compilation errors or search results.
  local orig_qflist = vim.fn.getqflist()
  local orig_qf_title = vim.fn.getqflist({ title = 0 }).title

  gitsigns.setqflist('all', { open = false }, function()
    vim.schedule(function()
      local hunk_items = vim.fn.getqflist()

      -- Immediately restore the user's original Quickfix list
      vim.fn.setqflist(orig_qflist, 'r')
      if orig_qf_title then
        vim.fn.setqflist({}, 'a', { title = orig_qf_title })
      end

      if not hunk_items or #hunk_items == 0 then
        vim.notify("No git hunks found", vim.log.levels.INFO)
        return
      end

      local sorted_hunks = M._sort_hunks(hunk_items, curr_buf, curr_file)
      open_hunks_picker(sorted_hunks, opts)
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("GitHunks", function()
    M.search_hunks()
  end, {
    desc = "Search Git hunks across the repository (current file first) using Telescope",
  })
end

return M
