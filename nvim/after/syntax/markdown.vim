syn match TagWord contained /[a-zA-Z0-9_-]\+/
syn match TagHash contained "#"
syn match TagLink / #[a-zA-Z]\+/ contains=TagWord,TagHash
" hi TagHash ctermfg=236 guifg='#333333'
hi link TagWord Tag
