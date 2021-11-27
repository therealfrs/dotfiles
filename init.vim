" vim: set fdm=marker fenc=utf-8 sw=2 ts=2:

let g:which_key_map = {}
let g:after_load = {}

exe 'source' expand('~/.config/nvim/basics.vim')
exe 'source' expand('~/.config/nvim/windows.vim')
exe 'source' expand('~/.config/nvim/google.vim')

set guicursor=n-c-v:block-Cursor/Cursor-blinkon0
set guicursor+=i-ci:ver1-Cursor/Cursor-blinkwait300-blinkon200-blinkoff150

nnoremap Y y$

" colorscheme lush_plain
set background=dark " or light if you want light mode
colorscheme gruvbox 

" read machine specific configuration
if filereadable(expand('~/.nvimrc.local'))
  source ~/.nvimrc.local
end

" Placeholder to be customised by local configs.
lua function _G.local_plugins(use) end
let s:local_init=expand("~/.config/nvim/") . join(split(hostname(), '\.')[0:1],".") . ".vim"

if filereadable(s:local_init)
  exe 'source' s:local_init
end

set mouse=a

lua require('plugins')

for key in keys(g:after_load)
  call g:after_load[key]()
endfor

lua << EOF
local nvim_lsp = require'lspconfig'
local configs = require'lspconfig/configs'
configs.ciderlsp = {
 default_config = {
   cmd = {'/google/bin/releases/cider/ciderlsp/ciderlsp', '--tooltag=nvim-lsp' , '--noforward_sync_responses'};
   filetypes = {'c', 'cpp', 'java', 'proto', 'textproto', 'go', 'python', 'bzl'};
   root_dir = nvim_lsp.util.root_pattern('BUILD');
   settings = {};
 };
}
nvim_lsp.ciderlsp.setup{}
EOF

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=100}
augroup END
