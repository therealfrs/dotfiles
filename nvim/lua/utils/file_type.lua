-- A Neovim Lua module to run set parameters for file types.
local M = {}

function M.setup()

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.opt_local.spell = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    callback = function()
      vim.opt_local.textwidth = 72
      vim.opt_local.colorcolumn = "72"
      vim.opt_local.spell = true
    end,
})

end

return M
