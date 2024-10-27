local zenburn = require'zenburn'
local vscode = require'vscode'

zenburn.setup({}) 
vscode.setup({style='light'}) 

vim.cmd.colorscheme('zenburn')
vim.g.reading_mode = false
