local kanagawa = require'kanagawa'
local vscode = require'vscode'

kanagawa.setup({}) 
vscode.setup({style='light'}) 

vim.cmd.colorscheme('alabaster')
vim.opt.background = 'light'
vim.g.reading_mode = false
