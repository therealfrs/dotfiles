vim.cmd [[packadd packer.nvim]]

local packer = nil

local function init()
    if packer == nil then
        packer = require 'packer'
        packer.init { disable_commands = true }
    end
    local use = packer.use

  use 'wbthomason/packer.nvim'

  use { 'itchyny/lightline.vim', config = [[require('config.lightline')]] }

  use {
    'tpope/vim-commentary',
    config = [[
      local map = require('config.utils').map
      map('n', '\\\\', 'gcc', {noremap = false})
      map('v', '\\\\', 'gcc', {noremap = false})
    ]],
  }



  use {
    'nvim-telescope/telescope.nvim',
    requires = { 
      { 'nvim-lua/popup.nvim' }, 
      { 'nvim-lua/plenary.nvim' }, 
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    },
    config = [[require('config.telescope')]],
  }

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
  use { 'nvim-treesitter/nvim-treesitter-context' }


  -- LSP
  use {'kabouzeid/nvim-lspinstall' }
  use { 'neovim/nvim-lspconfig', config = [[require('config.lsp')]] }
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
    'hrsh7th/vim-vsnip',
    config = [[require('config.vsnip')]],
    event = 'InsertEnter *',
  }
  use { 'hrsh7th/vim-vsnip-integ' }
  use {
    'hrsh7th/nvim-cmp',
    config = [[require('config.cmp')]],
    requires = {
      'hrsh7th/cmp-omni',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'ray-x/cmp-treesitter',
      'andersevenrud/cmp-tmux',
    },
  }

  -- Completion on :,/,etc.
  use {
    'gelguy/wilder.nvim',
    config = function()
      vim.api.nvim_exec([[call config#wilder()]], false)
    end,
    requires = { 'romgrk/fzy-lua-native', 'nixprime/cpsm' },
  }

  -- color schemes
  use {"ellisonleao/gruvbox.nvim"}

  use 'simrat39/symbols-outline.nvim'
  
  use { 
    'junegunn/fzf', 
    run = './install --bin', 
    config = [[require('config.fzf')]],
  }

  -- code formatter
  use {
    'google/vim-codefmt',
    requires = {
      'google/maktaba',
      'google/glaive',
    }
  }

  -- install cppman first using
  -- `pip install cppman`
  use {'gauteh/vim-cppman' }

  use {
    'mhinz/vim-signify',
    -- cmd = { 'SignifyToggle' },
    -- config = function()
    --   vim.g['signify_vcs_list'] = {'git'}
    --   vim.g['signify_vcs_cmds'] = { ['git'] = 'git diff -r .^ --config defaults.diff= --nodates -U0 -- %f' }
    --   vim.g['signify_realtime'] = 1
    --   vim.g['signify_cursorhold_insert'] = 0
    --   vim.g['signify_cursorhold_normal'] = 0
    -- end,
  }

  _G.local_plugins(use)
end

require('packer').startup(init)
