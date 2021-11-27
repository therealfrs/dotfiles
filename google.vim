" fix format after save
if &diff
  command W w
else
  command -bar F silent exec "!hg fixwdir"
  command W w | F | e | redraw! 
  command WA wa | F | windo e | redraw!
endif
