set background=dark
let g:colors_name="lush_plain"

lua package.loaded['lush_theme.plain'] = nil
lua require('lush')(require('lush_theme.plain'))

" hi! Cursor ctermfg=1 ctermbg=1 guifg=#FF0000 guibg=#FF0000
