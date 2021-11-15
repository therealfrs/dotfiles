set rtp+=~/.fzf

set encoding=utf-8
set statusline=2


syntax on
filetype on
filetype plugin on
filetype plugin indent on

set noswapfile

set wildmode=full
set wildmenu

set incsearch
set inccommand=nosplit
set nowrap

set novisualbell

set ignorecase
set smartcase

set clipboard& clipboard+=unnamed

let mapleader = " "

" make fname completion after equal signs work
set isfname-=\=

" Spaces&Tabs
set tabstop=2
set shiftwidth=2
set expandtab
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
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
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
