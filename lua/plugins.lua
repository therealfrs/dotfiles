-- vim.cmd [[packadd packer.nvim]]

local packer = nil

local function init()
    if packer == nil then
        packer = require 'packer'
        packer.init { disable_commands = true }
    end
    local use = packer.use

  use 'wbthomason/packer.nvim'

  use 'skywind3000/asyncrun.vim'

  use { 'itchyny/lightline.vim', config = [[require('config.lightline')]] }

  use { 'sjl/splice.vim' }
  use { 'junegunn/goyo.vim', cmd = { 'Goyo' } }


  use {
    'tpope/vim-commentary',
    config = [[
      local map = require('config.utils').map
      map('n', '\\\\', 'gcc', {noremap = false})
      map('v', '\\\\', 'gcc', {noremap = false})
    ]],
  }



  use {'nvim-telescope/telescope-fzy-native.nvim'}
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } },
    config = [[require('config.telescope')]],
  }

  -- use {'nvim-telescope/telescope-fzf-native.nvim', 
  --   run = 'make',
  --   config = [[require('config.telescope')]],
  -- }

  -- Treesitter
  use { 'nvim-treesitter/playground', cmd = { 'TSPlayground' } }

  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    run = ':TSUpdate',
    config = [[require('config.treesitter')]],
  }


  -- LSP
  use { 'onsails/lspkind-nvim', 'kabouzeid/nvim-lspinstall' }
  use { 'neovim/nvim-lspconfig', config = [[require('config.lsp')]] }
  use {
    'glepnir/lspsaga.nvim',
    config = function()
      require 'config.lspsaga'
      local map = require('config.utils').map
      map('n', 'K', ':Lspsaga hover_doc<CR>', { noremap = false, silent = true })
    end,
  }
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('trouble').setup {}
    end,
  }

  use {
      "folke/which-key.nvim",
      config = [[require('config.keymap')]],
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    config = [[require('config.cmp')]],
    requires = {
      'hrsh7th/cmp-omni',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      -- 'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'ray-x/cmp-treesitter',
      'andersevenrud/cmp-tmux',
    },
  }

  -- use {
  --   'hrsh7th/vim-vsnip',
  --   config = [[require('config.vsnip')]],
  --   event = 'InsertEnter *',
  -- }
  -- use { 'hrsh7th/vim-vsnip-integ' }

  -- Completion on :,/,etc.
  use {
    'gelguy/wilder.nvim',
    config = function()
      vim.api.nvim_exec([[call config#wilder()]], false)
    end,
    requires = { 'romgrk/fzy-lua-native', 'nixprime/cpsm' },
  }
  

  -- color schemes
  use {"ellisonleao/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}


  use 'cideM/yui'
  use 'davidosomething/vim-colors-meh'

  use 'simrat39/symbols-outline.nvim'
  
  use '~/.fzf'
  use 'junegunn/fzf.vim'


  use {
    'mhinz/vim-signify',
    -- cmd = { 'SignifyToggle' },
    config = function()
      vim.g['signify_vcs_list'] = {'hg'}
      vim.g['signify_vcs_cmds'] = { ['hg'] = 'hg diff -r .^ --config defaults.diff= --nodates -U0 -- %f' }
      vim.g['signify_realtime'] = 1
      vim.g['signify_cursorhold_insert'] = 0
      vim.g['signify_cursorhold_normal'] = 0
    end,
  }

  -- google specific
  use { 
      'sso://googler@user/vintharas/telescope-codesearch.nvim', 
      requires = {'nvim-telescope/telescope.nvim'},
      config = [[require('config.telescope_codesearch')]],
  }
  use {'google/vim-codefmt', requires = {'google/vim-maktaba'}}
  -- use {'sso://googler@user/codefmt-google', requires = {'google/vim-maktaba', 'google/vim-codefmt', 'google/codefmt'}, config = [[
  --   augroup autoformat_settings
  --       autocmd FileType borg,gcl,patchpanel AutoFormatBuffer gclfmt
  --       autocmd FileType bzl AutoFormatBuffer buildifier
  --       autocmd FileType c,cpp,javascript,typescript AutoFormatBuffer clang-format
  --       autocmd FileType dart AutoFormatBuffer dartfmt
  --       autocmd FileType go AutoFormatBuffer gofmt
  --       autocmd FileType java AutoFormatBuffer google-java-format
  --       autocmd FileType jslayout AutoFormatBuffer jslfmt
  --       autocmd FileType markdown AutoFormatBuffer mdformat
  --       autocmd FileType ncl AutoFormatBuffer nclfmt
  --       autocmd FileType python AutoFormatBuffer pyformat
  --       autocmd FileType soy AutoFormatBuffer soyfmt
  --       autocmd FileType textpb AutoFormatBuffer text-proto-format
  --       autocmd FileType proto AutoFormatBuffer protofmt
  --       autocmd FileType sql AutoFormatBuffer format_sql
  --       " autocmd FileType html,css,json AutoFormatBuffer js-beautify
  --   augroup END
  --   ]],
  --   }

  _G.local_plugins(use)
end

require('packer').startup(init)
