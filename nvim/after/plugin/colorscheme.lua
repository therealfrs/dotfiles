local kanagawa = require'kanagawa'
local vscode = require'vscode'

kanagawa.setup({}) 
vscode.setup({style='light'}) 

vim.cmd.colorscheme('kanagawa')
vim.g.reading_mode = false
