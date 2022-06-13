local wk = require 'which-key'
wk.setup {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
}

-- scope files to be search under google3
-- local find_files_cmd = { "rg", "-i", "--files", "-g", "!.git"}

local keymap_comma = {
  name = 'comma',
  r = {
    function()
      require('telescope.builtin').oldfiles { }
    end,
    'recent files',
  },
  p = {
    function()
      require('telescope.builtin').git_status {
        -- find_command = { 'git', 'status', '-s'},
      }
    end,
    'changed files',
  },
  f = { 
  function()
      require('telescope.builtin').find_files {
          -- find_command = find_files_cmd,
      }
  end,
  'common files'
  },
  d = { 
      function()
        require('telescope.builtin').find_files {
          cwd = '%:h',
        }
      end,
    'files in dir'
  },
  b = {
    function()
      require('telescope.builtin').buffers { }
    end,
    'buffers',
  },
  g = { 
      function()
          require('telescope.builtin').live_grep {
              -- cwd = '%:h',
          }
      end,
      'live grep'
  },
  w = { 
      function()
          require('telescope.builtin').grep_string {
            search = vim.fn.expand("<cword>"),
          }
      end,
      'live grep'
  },
  q = { 
      function()
          require('telescope.builtin').quickfix {
          }
      end,
      'quick fix'
  },
  j = {
      function()
          require('telescope.builtin').jumplist {
          }
      end,
      'jump list'
  },
}
wk.register(keymap_comma, { prefix = ',' })

local keymap_s = {
  name = 'window',
  p = { '<Cmd>lua require"windows".split_nicely()<CR>', 'split (smart)' },
  c = { '<Cmd>lua require"windows".smart_close()<CR>', 'close' },
  h = { '<Cmd>split<CR>', 'split horizontal' },
  v = { '<Cmd>vsplit<CR>', 'split vertical' },
  o = { ':<C-u>only<CR>', 'only' },
  s = { '<Cmd>ChooseWin<CR>', 'pick window' },
}
wk.register(keymap_s, { prefix = 's' })

local keymap_space = {
  name = 'space',
  wa = { '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>' },
  wr = { '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>' },
  wl = {
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
  },
  D = { '<cmd>lua vim.lsp.buf.type_definition()<CR>' },
  -- K = {'<cmd>lua vim.lsp.buf.signature_help()<CR>'},
  -- h = {'<cmd>lua vim.lsp.buf.hover()<CR>'},
  -- r = {'<cmd>lua vim.lsp.buf.rename()<CR>'},
  -- ca = {'<cmd>lua vim.lsp.buf.code_action()<CR>'},
  -- e = {'<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>'}
  b = {
    name = 'debug',
    c = { '<Cmd>:lua require"dap".continue()<CR>', 'continue (dap)' },
    s = { '<Cmd>:lua require"dap".step_over()<CR>', 'step over(dap)' },
    i = { '<Cmd>:lua require"dap".step_into()<CR>', 'step into (dap)' },
    o = { '<Cmd>:lua require"dap".step_out()<CR>', 'step out (dap)' },
    b = {
      '<Cmd>:lua require"dap".toggle_breakpoint()<CR>',
      'toggle breakpoint (dap)',
    },
    B = {
      '<Cmd>:lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
      'toggle breakpoint',
    },
    l = {
      '<Cmd>:lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
      'toggle logpoint',
    },
    R = { '<Cmd>:lua require"dap".repl.open()<CR>', 'REPL open' },
    r = { '<Cmd>:lua require"dap".run_last()<CR>', 'run last (dap)' },
  },
}
wk.register(keymap_space, { prefix = '<space>' })

local keymap_g = {
  name = 'go',
  d = { '<Cmd>Telescope lsp_definitions <CR>', 'LSP definitions' },
  D = { '<Cmd>lua vim.lsp.buf.definition()<CR>', 'LSP definition' },
  i = { '<Cmd>Telescope lsp_implementation<CR>', 'LSP implementation' },
  r = {'<Cmd>Telescope lsp_references<CR>', 'LSP references'},
  s = { '<Cmd>call swap#prerequisite("n")<CR>g@l', 'swap interactive' },
}
wk.register(keymap_g, { prefix = 'g' })

local keymap_Q = {
  n = { '<cmd>cnext<CR>', 'cnext' },
  p = { '<cmd>cprevious<CR>', 'cprev' },
  o = { '<cmd>:botright cwindow<CR>', 'cwindow' },
  c = { '<cmd>:cclose<CR>', 'cclose' },
}
wk.register(keymap_Q, { prefix = 'Q' })

vim.api.nvim_set_keymap('n', '<C-p>', ":FZF<CR>", {noremap = true, silent = true })
vim.api.nvim_set_keymap('v', ',g', "y<ESC>:Telescope live_grep default_text=<c-r>0<CR>", {noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-c>', '<ESC>', {noremap = true, silent = true })

curr_buffer_keymap = function()
  local builtin = require("telescope.builtin")
  local themes = require("telescope.themes")
  local opt = themes.get_ivy({sorting_strategy="ascending"})
  builtin.current_buffer_fuzzy_find(opt)
end

vim.api.nvim_set_keymap(
  'n',
  '<C-_>',
  '<cmd>lua curr_buffer_keymap()<CR>',
  {noremap = true, silent = true }
)

-- Some VimL mappings
vim.api.nvim_exec(
  [[
map ; :
cnoremap <C-g> <C-r>=getline('.')<cr>
inoremap jj <Esc>
" inoremap jk <Esc>

" terminal mapping
tnoremap <Esc> <C-\><C-n>

map Q <nop>

vnoremap <leader>= :<C-u> FormatLines<CR>"
vnoremap <leader>fr :<C-u> FormatLines<CR>"
nnoremap <leader>fc :<C-u> FormatCode<CR>"

" like <Enter>, but returns to the quickfix window
autocmd BufReadPost quickfix map <buffer> <Space> <CR>z.<C-W>w

" :w!! writes to a file using sudo if you forgot to "sudo vim file"
cmap w!! %!sudo tee > /dev/null %

map <Leader>v :e ~/.config/nvim/init.vim<CR>

" Movement {{{2
map <C-Down> <C-d>
map <C-Up> <C-u>

" Tab movement {{{2

" map tc :tabnew<CR>:bn<CR>
" map td :tabclose<CR>

augroup MyAutoCmd
  autocmd FileType help :map <buffer> q :q<cr>
  autocmd FileType ref-man :map <buffer> q :q<cr>
  autocmd FileType python :vmap <buffer> <S-Enter> "+y:<c-u>call
augroup END

]],
  false
)
