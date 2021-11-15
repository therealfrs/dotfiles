" Vim color file
" Maintainer: Lisie Michel

" Google color scheme

set background=dark

hi clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name='googledark'


" Colors for the User Interface.

hi Cursor       guibg=#EEEEEE  guifg=black    gui=bold
hi Normal       guibg=black    guifg=#4285F4  gui=none
hi NonText      guibg=black    guifg=#EEEEEE  gui=bold
hi Visual       guibg=#656565  guifg=NONE     gui=none
" hi VisualNOS

hi Linenr       guibg=#656565  guifg=#EEEEEE  gui=none
hi ColorColumn  guibg=#656565  guifg=NONE     gui=none

hi Directory    guibg=bg       guifg=#0F9D58  gui=none

hi IncSearch    guibg=#EEEEEE  guifg=black    gui=none
hi Search       guibg=#EEEEEE  guifg=black    gui=none
hi SpecialKey   guibg=bg       guifg=fg       gui=none
hi Titled       guibg=bg       guifg=fg       gui=none

hi ErrorMsg     guibg=bg       guifg=#DB4437  gui=bold
hi ModeMsg      guibg=bg       guifg=#4285F4  gui=none
hi link MoreMsg  ModeMsg
hi link Question ModeMsg
hi WarningMsg   guibg=bg       guifg=#DB4437  gui=bold

hi StatusLine   guibg=#EEEEEE  guifg=#656565  gui=bold
hi StatusLineNC guibg=#656565  guifg=#EEEEEE  gui=none
hi VertSplit    guibg=#EEEEEE  guifg=#656565  gui=none
hi MatchParen   guibg=#DB4437  guifg=black    gui=none

" hi Folded
" hi FoldColumn
" hi SignColumn


" Colors for Syntax Highlighting.

hi Comment        guibg=bg  guifg=#0F9D58 gui=none

hi Constant       guibg=bg  guifg=#EEEEEE gui=none
hi String         guibg=bg  guifg=#DB4427 gui=italic
hi Character      guibg=bg  guifg=#DB4427 gui=italic
hi Number         guibg=bg  guifg=#EEEEEE gui=none
hi Boolean        guibg=bg  guifg=#EEEEEE gui=none
hi Float          guibg=bg  guifg=#EEEEEE gui=none

hi Identifier     guibg=bg  guifg=#003399 gui=none
hi Function       guibg=bg  guifg=#4285F4 gui=bold
hi Statement      guibg=bg  guifg=#DB4437 gui=bold

hi Conditional    guibg=bg  guifg=#DB4437 gui=bold
hi Repeat         guibg=bg  guifg=#DB4437 gui=bold
hi link Label     Conditional
hi Operator       guibg=bg  guifg=#EEEEEE gui=bold
hi link Keyword   Statement
hi Exception      guibg=bg  guifg=#DB4437 gui=bold

hi PreProc        guibg=bg  guifg=#0F9D58 gui=bold
hi Include        guibg=bg  guifg=#0F9858 gui=bold
hi link Define    Include
hi link Macro     Include
hi link PreCondit Include

hi Type           guibg=bg  guifg=#F4B400 gui=bold
hi link StorageClass Type
hi link Structure    Type
hi Typedef        guibg=bg  guifg=#0F9D58 gui=italic

hi Special        guibg=bg  guifg=fg      gui=none
hi SpecialChar    guibg=bg  guifg=fg      gui=bold
hi Tag            guibg=bg  guifg=#EEEEEE gui=bold
hi link Delimiter Special
hi SpecialComment guibg=bg  guifg=#0F9D58 gui=bold
hi link Debug     Special

hi Underlined     guibg=bg  guifg=#EEEEEE gui=underline

hi Title    guibg=bg        guifg=fg      gui=bold
hi Ignore   guibg=bg        guifg=#EEEEEE gui=none
hi Error    guibg=#DB4437   guifg=black   gui=none
hi Todo     guibg=#F4B400   guifg=black   gui=none


" For console vim
"
" For an authentically Googley display, edit the color settings in your terminal
" to the following RGB codes
" blue    =#4285F4
" green   =#0F9D58
" red     =#DB4437
" yellow  =#F4B400
" darkgrey=#656565
" grey    =#EEEEEE


hi Cursor       ctermbg=grey      ctermfg=black     cterm=bold
hi Normal       ctermbg=black     ctermfg=blue      cterm=none
hi NonText      ctermbg=black     ctermfg=grey      cterm=bold
hi Visual       ctermbg=darkgrey  ctermfg=NONE      cterm=none
" hi VisualNOS

hi Linenr       ctermbg=darkgrey  ctermfg=grey      cterm=none
hi ColorColumn  ctermbg=darkgrey  ctermfg=NONE      cterm=none

hi Directory    ctermbg=bg        ctermfg=green     cterm=none

hi IncSearch    ctermbg=grey      ctermfg=black     cterm=none
hi Search       ctermbg=grey      ctermfg=black     cterm=none
hi SpecialKey   ctermbg=bg        ctermfg=fg        cterm=none
hi Titled       ctermbg=bg        ctermfg=fg        cterm=none

hi ErrorMsg       ctermbg=bg      ctermfg=red       cterm=bold
hi ModeMsg        ctermbg=bg      ctermfg=blue      cterm=none
hi link MoreMsg   ModeMsg
hi link Question  ModeMsg
hi WarningMsg     ctermbg=bg      ctermfg=red       cterm=bold

hi StatusLine   ctermbg=grey      ctermfg=darkgrey  cterm=bold
hi StatusLineNC ctermbg=darkgrey  ctermfg=grey      cterm=none
hi VertSplit    ctermbg=grey      ctermfg=darkgrey  cterm=none
hi MatchParen   ctermbg=red       ctermfg=black     cterm=none

" hi Folded
" hi FoldColumn
" hi SignColumn


" Colors for Syntax Highlighting.

hi Comment         ctermbg=bg    ctermfg=green    cterm=none

hi Constant        ctermbg=bg    ctermfg=grey     cterm=none
hi String          ctermbg=bg    ctermfg=red      cterm=none
hi Character       ctermbg=bg    ctermfg=red      cterm=none
hi Number          ctermbg=bg    ctermfg=grey     cterm=none
hi Boolean         ctermbg=bg    ctermfg=grey     cterm=none
hi Float           ctermbg=bg    ctermfg=grey     cterm=none

hi Identifier      ctermbg=bg    ctermfg=blue     cterm=bold
hi Function        ctermbg=bg    ctermfg=blue     cterm=bold
hi Statement       ctermbg=bg    ctermfg=red      cterm=bold

hi Conditional     ctermbg=bg    ctermfg=red      cterm=bold
hi Repeat          ctermbg=bg    ctermfg=red      cterm=bold
hi link  Label     Conditional
hi Operator        ctermbg=bg    ctermfg=grey     cterm=bold
hi link Keyword    Statement
hi Exception       ctermbg=bg    ctermfg=red      cterm=bold

hi PreProc         ctermbg=bg    ctermfg=green    cterm=bold
hi Include         ctermbg=bg    ctermfg=green    cterm=bold
hi link Define     Include
hi link Macro      Include
hi link PreCondit  Include

hi Type            ctermbg=bg    ctermfg=yellow   cterm=bold
hi link StorageClass Type
hi link Structure    Type
hi Typedef         ctermbg=bg    ctermfg=green    cterm=none

hi Special         ctermbg=bg    ctermfg=fg       cterm=none
hi SpecialChar     ctermbg=bg    ctermfg=fg       cterm=bold
hi Tag             ctermbg=bg    ctermfg=grey     cterm=bold
hi link Delimiter  Special
hi SpecialComment  ctermbg=bg    ctermfg=green    cterm=bold
hi link Debug      Special

hi Underlined      ctermbg=bg    ctermfg=grey     cterm=underline

hi Title          ctermbg=bg     ctermfg=fg       cterm=bold
hi Ignore         ctermbg=bg     ctermfg=grey     cterm=none
hi Error          ctermbg=red    ctermfg=white    cterm=none
hi Todo           ctermbg=yellow ctermfg=white    cterm=none

