local zenburn = require'kanagawa'
local vscode = require'vscode'

zenburn.setup({}) 
vscode.setup({style='light'}) 

vim.cmd.colorscheme('kanagawa')
vim.g.reading_mode = false
