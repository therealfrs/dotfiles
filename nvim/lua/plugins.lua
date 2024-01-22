vim.cmd [[packadd packer.nvim]]

local packer = nil

local function init()
    if packer == nil then
        packer = require 'packer'
        packer.init { disable_commands = true }
    end
    local use = packer.use

  use 'wbthomason/packer.nvim'

  use { 'itchyny/lightline.vim' }

  use {
    'tpope/vim-commentary',
   config = [[
      local map = require('utils').map
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
  }
  use { 'nvim-treesitter/nvim-treesitter-context' }


  -- LSP
  use {'kabouzeid/nvim-lspinstall' }
  use { 'neovim/nvim-lspconfig' }
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  use {
      "folke/which-key.nvim",
  }

  -- Completion
  use {
    'hrsh7th/vim-vsnip',
    event = 'InsertEnter *',
  }
  use { 'hrsh7th/vim-vsnip-integ' }
  use {
    'hrsh7th/nvim-cmp',
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
    requires = { 'romgrk/fzy-lua-native', 'nixprime/cpsm' },
  }

  -- color schemes
  use {"sainnhe/gruvbox-material"}
  use {
    "phha/zenburn.nvim",
    config = function() 
      require("zenburn").setup() 
      -- Hide all semantic highlights
      for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
      end
    end
  }

  use 'simrat39/symbols-outline.nvim'
  
  use { 
    'junegunn/fzf', 
    run = './install --bin', 
  }

  -- install cppman first using
  -- `pip install cppman`
  use {'gauteh/vim-cppman'}

  use { 'mhinz/vim-signify' }

  _G.local_plugins(use)
end

require('packer').startup(init)
