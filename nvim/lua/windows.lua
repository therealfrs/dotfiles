local M = {}

local cmd = vim.cmd
local call = vim.call

function M.split_nicely()
  if vim.api.nvim_win_get_width(0) > 2 * vim.api.nvim_get_option('winwidth') then
    cmd('vsplit')
  else
    cmd('split')
  end
  cmd('wincmd p')
end

function M.smart_close()
  if call('winnr', '$') ~= 1 then cmd('close') end
end

return M
