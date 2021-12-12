
" The prefix key.
" nmap s s
nnoremap <silent> <leader>sp :<C-u>call <SID>split_nicely()<CR>
nnoremap <silent> <leader>sv :<C-u>vsplit<CR>
nnoremap <silent> <leader>sc :<C-u>call <sid>smart_close()<CR>
nnoremap <silent> <leader>so :<C-u>only<CR>


" A .vimrc snippet that allows you to move around windows beyond tabs
nnoremap <silent> <Tab> :call <SID>NextWindow()<CR>
nnoremap <silent> <S-Tab> :call <SID>NextWindowOrTab()<CR>
tmap <silent> <S-Tab> <Esc><Tab>

" nnoremap <silent> s<Space> :<C-u>call <SID>ToggleSplit()<CR>
nnoremap <silent> s<Space> :ChooseWin<CR>

nnoremap <silent> sd :<C-u>call <SID>CustomBufferDelete(0)<CR>
" Force delete current buffer.
nnoremap <silent> sD :<C-u>call <SID>CustomBufferDelete(1)<CR>

function! s:smart_close() "{{{
  if winnr('$') != 1
    close
  endif
endfunction "}}}

function! s:NextWindow() "{{{
  if winnr('$') == 1
    silent! normal! ``z.
  else
    wincmd w
  endif
endfunction "}}}

function! s:NextWindowOrTab() "{{{
  if tabpagenr('$') == 1 && winnr('$') == 1
    call s:split_nicely()
  elseif winnr() < winnr("$")
    wincmd w
  else
    tabnext
    1wincmd w
  endif
endfunction "}}}

function! s:PreviousWindowOrTab() "{{{
  if winnr() > 1
    wincmd W
  else
    tabprevious
    execute winnr("$") . "wincmd w"
  endif
endfunction "}}}

" If window isn't splited, split buffer.
function! s:ToggleSplit() " {{{
  let prev_name = winnr()
  silent! wincmd w
  if prev_name == winnr()
    call s:split_nicely()
  else
    call s:smart_close()
  endif
endfunction " }}}

function! s:split_nicely() " {{{
  if winwidth(0) > 2 * &winwidth
    vsplit
  else
    split
  endif
  wincmd p
endfunction
"}}}

" Delete current buffer.
function! s:CustomBufferDelete(is_force) " {{{
  let current = bufnr('%')

  call s:alternate_buffer()

  if a:is_force
    silent! execute 'bdelete! ' . current
  else
    silent! execute 'bdelete ' . current
  endif
endfunction
"}}}

function! s:alternate_buffer() "{{{
  let listed_buffer_len = len(filter(range(1, bufnr('$')),
        \ 's:buflisted(v:val) && getbufvar(v:val, "&filetype") !=# "unite"'))
  if listed_buffer_len <= 1
    enew
    return
  endif

  let cnt = 0
  let pos = 1
  let current = 0
  while pos <= bufnr('$')
    if s:buflisted(pos)
      if pos == bufnr('%')
        let current = cnt
      endif

      let cnt += 1
    endif

    let pos += 1
  endwhile

  if current > cnt / 2
    bprevious
  else
    bnext
  endif
endfunction"}}}

function! s:buflisted(bufnr) "{{{
  return exists('t:unite_buffer_dictionary') ?
        \ has_key(t:unite_buffer_dictionary, a:bufnr) && buflisted(a:bufnr) :
        \ buflisted(a:bufnr)
endfunction "}}}

