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
  { ",", group = "comma" },
  { ",r", 
    function()
      require('telescope.builtin').oldfiles { }
    end,
    desc = 'recent files',
  },
  { ",p",
    function()
      require('telescope.builtin').git_status {
        -- find_command = { 'git', 'status', '-s'},
      }
    end,
    desc = 'changed files',
  },
  { ",u",
    function()
      require('utils.git').search_hunks()
    end,
    desc = 'hunks',
  },
  { ",f",
    function()
      require('telescope.builtin').find_files {
        -- find_command = find_files_cmd,
      }
    end,
    desc = 'common files'
  },
  { ",d",
    function()
      require('telescope.builtin').find_files {
        cwd = '%:h',
      }
    end,
    desc = 'files in dir'
  },
  { ",b",
    function()
      require('telescope.builtin').buffers { }
    end,
    desc = 'buffers',
  },
  { ",g",
    function()
      require('telescope.builtin').live_grep {
        -- cwd = '%:h',
      }
    end,
    desc = 'live grep'
  },
  { ",w",
    function()
      require('telescope.builtin').grep_string {
        search = vim.fn.expand("<cword>"),
      }
    end,
    desc = 'live grep'
  },
  { ",q",
    function()
      require('telescope.builtin').quickfix {
      }
    end,
    desc = 'quick fix'
  },
  { ",j",
    function()
      require('telescope.builtin').jumplist {
      }
    end,
    desc = 'jump list'
  },
  { ",h", 
    function()
      require('telescope.builtin').command_history { }
    end,
    desc = 'commnad history',
  },
}
wk.add(keymap_comma)

local keymap_g = {
  { "g", group = "go" },
  { "gD", "<Cmd>lua vim.lsp.buf.definition()<CR>", desc = "LSP definition" },
  { "gd", "<Cmd>Telescope lsp_definitions <CR>", desc = "LSP definitions" },
  { "ge", "<Cmd>lua vim.diagnostic.open_float()<CR>", desc = "Diagnostic error" },
  { "gi", "<Cmd>Telescope lsp_implementation<CR>", desc = "LSP implementation" },
  { "gr", "<Cmd>Telescope lsp_references<CR>", desc = "LSP references" },
  { "gs", '<Cmd>call swap#prerequisite("n")<CR>g@l', desc = "swap interactive" },
}
wk.add(keymap_g)

local keymap_Q = {
  {"Q", group = "Q"},
  { "Qc", "<cmd>:cclose<CR>", desc = "cclose" },
  { "Qn", "<cmd>cnext<CR>", desc = "cnext" },
  { "Qo", "<cmd>:botright cwindow<CR>", desc = "cwindow" },
  { "Qp", "<cmd>cprevious<CR>", desc = "cprev" },
}
wk.add(keymap_Q)

local keymap_git = {
  { "<leader>g", group = "git" },
  { "<leader>gd", "<cmd>Gitsigns diffthis<CR>", desc = "diff split (current file)" },
  { "<leader>gs", function()
      require('utils.git').search_hunks()
    end,
    desc = "search hunks (telescope)"
  },
  { "<leader>gv", "<cmd>DiffviewOpen -- %<CR>", desc = "diffview (current file)" },
  { "<leader>gV", "<cmd>DiffviewOpen<CR>", desc = "diffview (all files)" },
  { "<leader>gh", function()
      require('gitsigns').toggle_linehl()
      require('gitsigns').toggle_word_diff()
    end,
    desc = "toggle inline highlights"
  },
}
wk.add(keymap_git)

vim.api.nvim_set_keymap('n', '<C-p>', ":FZF<CR>", {noremap = true, silent = true })
vim.api.nvim_set_keymap('v', ',g', "y<ESC>:Telescope live_grep default_text=<c-r>0<CR>", {noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-c>', '<ESC>', {noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-c>', '<ESC>', {noremap = true, silent = true })

toggle_read_mode = function()
  vim.cmd.hi('clear')

  vim.g.reading_mode = not vim.g.reading_mode
  if vim.g.reading_mode then
    vim.cmd.colorscheme('vscode')
  else
    vim.cmd.colorscheme('kanagawa')
  end
end

vim.api.nvim_set_keymap('n', '<leader>r', '<cmd>lua toggle_read_mode()<CR>', {noremap = true, silent = true})

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

map <Leader>v :e ~/.config/nvim/init.lua<CR>

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
