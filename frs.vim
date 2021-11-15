lua <<EOF
function _G.local_plugins(use)
  use {'sso://user/vintharas/telescope-codesearch.nvim', config = function()
    require('telescope').load_extension('codesearch')
  end}
end
EOF

nnoremap <silent> ,cf :<C-u>Telescope codesearch find_files<CR>
nnoremap <silent> ,cq :<C-u>Telescope codesearch find_query<CR>

function! after_load.colour()
    hi Comment guifg=#c1c3cc ctermfg=251 guibg=#2e3459 ctermbg=236 gui=NONE cterm=NONE

    hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
    hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
    hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow

    hi LspDiagnosticsVirtualTextError guifg=#ff0000
    hi LspDiagnosticsVirtualTextWarning  guifg=#ffaa00
    hi LspDiagnosticsVirtualTextInformation  guifg=#cccccc
    hi LspDiagnosticsVirtualTextHint  guifg=#cccccc
endfunction

"Normal mode.
nnoremap <leader>cf :let g:clang_include_fixer_query_mode=0<cr>:py3f /usr/lib/clang-include-fixer/clang-include-fixer.py<cr>
"Query mode.
nnoremap <leader>qf :let g:clang_include_fixer_query_mode=1<cr>:py3f /usr/lib/clang-include-fixer/clang-include-fixer.py<cr>

if !&diff
  source  /usr/share/vim/google/google.vim
  Glug glug sources^='/google/src/head/depot/google3/experimental/users/gunand/vim'

  " Glug simplegutter
  " Glug sg_blaze plugin[mappings]='cz' auto_query=1

  " Glug blazedeps auto_filetypes=`['go']`
  " Glug codefmt gofmt_executable="goimports"
  Glug codefmt-google
  Glug google-filetypes
  Glug googlestyle
  Glug blazedeps
  Glug relatedfiles plugin[mappings]=',R'
  " Glug outline-window

  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType go :set ts=2
endif


function! PPGDiff()
  if exists("s:ppgdiffbuf")
    " turn off diff
    exec "bd " . s:ppgdiffbuf
    unlet s:ppgdiffbuf
    diffoff
    return
  endif
  exec "vert diffsplit " . GetOriginalSource(expand("%:p"))
  let s:ppgdiffbuf = winbufnr(0)
  wincmd l
endfunction

nmap <silent> <Leader>gd :call PPGDiff()<CR>


" auto-correct imports
" trim trailing whitespace
" collapse any excessive blank lines to a maximum of 2 (could be made smarter)
function Fiximports ()
  silent %!/google/data/ro/teams/python-team/importorder --filein %:p
  %s/\s\+$//e
endfunction
command Fiximports call Fiximports ()


let test#custom_runners = {'Cpp': ['BlazeTest']}
let test#strategy = 'neovim'
let test#strategy = 'asyncrun_background_term'

let g:neomake_blazebuild_maker = {
      \ 'exe': 'blaze',
      \ 'args': ['build', ':all'],
      \ 'errorformat': '%f:%l:%c: %m',
      \ }
