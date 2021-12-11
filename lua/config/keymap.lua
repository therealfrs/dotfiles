-- local wk = require('whichkey_setup')
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

-- vim.api.nvim_set_option('timeoutlen',500)

local keymap_comma = {
  name = 'comma',
  r = {
    function()
      require('telescope.builtin').oldfiles {
        entry_maker = require('config.telescope_entry').gen_from_file(),
      }
    end,
    'recent files',
  },
  p = {
    function()
      require('telescope.builtin').find_files {
        find_command = { 'hg', 'status', '--rev=p4base', '-man' },
      }
    end,
    'changed files',
  },
  f = { 
  function()
      require('telescope.builtin').find_files {
          find_command = { "rg", "-i", "--hidden", "--files", "-g", "!.git", "platforms/security", "third_party/ecclesia", "platforms/ecclesia", "platforms/haven", "platforms/gsys", "security/notar", "security/crypta"},
      }
  end,
  'common files'
  },
  s = {
        function()
            require('telescope').extensions.codesearch.find_files{ }
        end,
  'codesearch files'
  },
  q = {
        function()
            require('telescope').extensions.codesearch.find_query{ }
        end,
  'codesearch files'
  },
  d = { '<Cmd>Telescope find_files cwd=%:h<CR>', 'files in dir' },
  b = { '<Cmd>Telescope buffers<CR>', 'buffers' },
  B = {
    function()
      require('telescope.builtin').buffers {
        entry_maker = require('config.telescope_entry').gen_from_buffer(),
      }
    end,
    'buffers',
  },
  g = { 
      function()
          require('telescope.builtin').live_grep {
              cwd = '%:h',
              -- find_command = {""}'<Cmd>Telescope live_grep cwd=%:h<CR>', 'live grep' 
          }
      end,
      'live grep'
  },
  n = { '<Cmd>Telescope find_files cwd=~/notes<CR>', 'notes' },
  N = {
    '<Cmd>cd ~/notes<CR>:Telescope tags ctags_file=~/notes/.tags<CR>',
    'note tags',
  },
}
wk.register(keymap_comma, { prefix = ',' })

-- local keymap_ctrl = {
--   name = 'control',
--   p = { 
--   function()
--       require('telescope.builtin').find_files {
--           find_command = { "rg", "-i", "--hidden", "--files", "-g", "!.git", "platforms/security", "third_party/ecclesia", "platforms/ecclesia", "platforms/haven", "platforms/gsys", "security/crypta"},
--       }
--   end,
--   'common files'
--   },
-- }
-- wk.register(keymap_ctrl, { prefix = '<Ctrl>' })

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
  K = { '<Cmd>:Lspsaga signature_help<CR>', 'signature help' },
  h = { '<Cmd>:Lspsaga hover_doc<CR>', 'hover doc' },
  -- h = {'<cmd>lua vim.lsp.buf.hover()<CR>'},
  -- r = {'<cmd>lua vim.lsp.buf.rename()<CR>'},
  r = { '<Cmd>:Lspsaga rename<CR>', 'rename' },
  s = { '<Cmd>:Lspsaga signature_help<CR>', 'signature help' },
  -- ca = {'<cmd>lua vim.lsp.buf.code_action()<CR>'},
  a = { '<Cmd>:Lspsaga code_action<CR>', 'preview definition' },
  d = { '<Cmd>:Lspsaga preview_definition<CR>', 'preview definition' },
  -- e = {'<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>'}
  e = { '<Cmd>:Lspsaga show_line_diagnostics<CR>', 'rename' },
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

--  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
--  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
--  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
--  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--
vim.api.nvim_set_keymap('n', '<C-p>',
":lua require('telescope.builtin').find_files { find_command = { 'rg', '-i', '--hidden', '--files', '-g', '!.git', 'platforms/security', 'third_party/ecclesia', 'platforms/ecclesia', 'platforms/haven', 'platforms/gsys', 'security/crypta'}, }<CR>",
{noremap = true, silent = true }
)

vim.api.nvim_set_keymap('n', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-c>', '<ESC>', {noremap = true, silent = true })


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
