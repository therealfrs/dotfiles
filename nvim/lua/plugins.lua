vim.cmd [[packadd packer.nvim]]

local packer = nil

local function init()
    if packer == nil then
        packer = require 'packer'
        packer.init { disable_commands = true }
    end
    local use = packer.use

  use 'wbthomason/packer.nvim'

  use 'itchyny/lightline.vim'

  use {
    'nvim-telescope/telescope.nvim',
    requires = { 
      { 'nvim-lua/popup.nvim' }, 
      { 'nvim-lua/plenary.nvim' }, 
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    },
  }

  -- LSP
  use {'kabouzeid/nvim-lspinstall' }
  use { 'neovim/nvim-lspconfig' }

  -- Smart key mapping
  use {
    "folke/which-key.nvim",
    requires = 'echasnovski/mini.icons',
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-omni',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'ray-x/cmp-treesitter',
    },
  }

  -- colorscheme
  use {
    "phha/zenburn.nvim",
    config = function() 
      require("zenburn").setup() 
    end
  }

  use { 
    'junegunn/fzf', 
    run = './install --bin', 
  }

  use { 'mhinz/vim-signify' }

  _G.local_plugins(use)
end

require('packer').startup(init)
