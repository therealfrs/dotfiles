vim.g.lightline = {
    colorscheme = 'darcula',
    component_function = {
        filename = 'LightLineFilename'
    }
}

vim.api.nvim_exec([[
function! LightLineFilename()
    let name = ""
    let subs = split(expand('%:p'), "/")[-4:-2]
    for s in subs
        let parent = name
        " let name = parent . '/' . strpart(s, 0, 3)
        let name = parent . s . '/'
    endfor
    return name . expand('%:t')
endfunction

function! ListLightlineColorschemes(A,L,P)
    return system("ls -1 " . g:plug_home . "/lightline.vim/autoload/lightline/colorscheme | cut -d. -f1")
endfunction

function! LightlineSetColorscheme(str)
try
    let g:lightline.colorscheme=a:str
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
    catch
    endtry
endfunction

command! -nargs=1 -complete=custom,ListLightlineColorschemes LightlineColorscheme call LightlineSetColorscheme(<q-args>)
]], false)
