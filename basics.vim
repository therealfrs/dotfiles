set rtp+=~/.fzf

set encoding=utf-8

syntax on
filetype plugin indent on

set wildmode=full
set wildmenu

set inccommand=nosplit
set novisualbell

set ignorecase
set smartcase

set clipboard& clipboard+=unnamed

let mapleader = " "

" Spaces&Tabs
set tabstop=2
set shiftwidth=2
set smarttab

" set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±'

set tags=./tags,./.tags
" Indenting 
set autoindent
set smartindent

" UI {{{1
set statusline=%n\ %F%m%r%h%w\ [%{&ff}]%y\ %=[char=\%03.3b\ 0x\%02.2B]\ [r=%04l,c=%03v][%03p%%]\ [lines=%L]
set laststatus=2
set winwidth=90

" Title length.
set title
set titlelen=95

" the cursorline is useful when working with multiple windows: it will highlight the current line in an inactive window
set cursorline

set guicursor=
set nohlsearch
set hidden
set noerrorbells
set expandtab
set nu
set nowrap
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8
" set noshowmode
set signcolumn=yes
set isfname+=@-@
" set ls=0

" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set colorcolumn=80

set grepprg=rg\ -L\ --vimgrep
set grepformat^=%f:%l:%c:%m

" Set clang-format as the default formatter
if executable('clang-format')
  set formatexpr=
  set formatprg=clang-format
endif

augroup AutoCursorLine
  " Turn on cursorline only on active window
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter,BufRead * setlocal cursorline
augroup END

if !has('gui_running')
    if has("terminfo")
        let &t_Sf=nr2char(27).'[3%p1%dm'
        let &t_Sb=nr2char(27).'[4%p1%dm'
    else
        let &t_Sf=nr2char(27).'[3%dm'
        let &t_Sb=nr2char(27).'[4%dm'
    endif
    set termguicolors
endif

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Chromium filetypes
augroup filetype
        au! BufRead,BufNewFile *.gyp    set filetype=python expandtab tabstop=2 shiftwidth=2
        au! BufRead,BufNewFile *.gypi   set filetype=python expandtab tabstop=2 shiftwidth=2
        au! BufRead,BufNewFile DEPS     set filetype=python expandtab tabstop=2 shiftwidth=2
        au! BufRead,BufNewFile cl_description* set filetype=gitcommit
        au! BufNewFile,BufRead *.star set syntax=python
        au! BufNewFile,BufRead *.gn set syntax=python
augroup END

" Chromium clang-format
let s:chromium_path = system("echo -n ${CHROMIUM_PATH}")
let s:script = s:chromium_path .
  \'/buildtools/clang_format/script/clang-format.py'
let s:shortcut = has('mac') ? "<D-k>" : "<C-k>"
let s:pyf = has("python3") ? ":py3f" : ":pyf"

execute "map" s:shortcut s:pyf s:script . "<CR>"
execute "imap" s:shortcut "<ESC>" s:pyf s:script . "<CR>i"
