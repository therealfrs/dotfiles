-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    {'nvim-lualine/lualine.nvim'},

    {
      'nvim-telescope/telescope.nvim',
      requires = { 
        { 'nvim-lua/popup.nvim' }, 
        { 'nvim-lua/plenary.nvim' }, 
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
      },
    },

    -- LSP
    {'kabouzeid/nvim-lspinstall' },
    { 
      'neovim/nvim-lspconfig',
      config = function()
        local nvim_lsp = require('lspconfig')
        local configs = require('lspconfig.configs')
        configs.clangd = {
          default_config = {
            -- cmd = {'/google/bin/releases/cider/ciderlsp/ciderlsp', '--tooltag=nvim-lsp' , '--noforward_sync_responses'};
            cmd = {'/usr/bin/clangd', '--header-insertion=never'};
            filetypes = {'c', 'cpp', 'java', 'go', 'bzl'};
            root_dir = nvim_lsp.util.root_pattern('compile_commands.json');
            settings = {};
          }
        }

        nvim_lsp.pylsp.setup{ }
        nvim_lsp.gopls.setup{}
        nvim_lsp.clangd.setup{
          on_attach = function(client, bufnr)
            local opts = { noremap = true, silent = true }
            require('lspconfig').clangd.setup {
              handlers = {
                ['textDocument/clangd.fileStatus'] = function(err, result, ctx, cfg)
                  local buf = vim.fn.bufnr(vim.uri_to_fname(result.uri))
                  if buf < 0 then return end
                  local state = ''
                  if result.state == 'idle' then
                    state = '✓'
                  elseif string.find(result.state, 'parsing include', 0, true) then
                    state = '⟳'
                  elseif string.find(result.state, 'queued', 0, true) then
                    state = '…'
                  end
                  vim.b[buf].lsp_status = state
                end
              },
              init_options = { clangdFileStatus = true },
            }
          end,
        }
      end,
    },

    -- Smart key mapping
    {
      "folke/which-key.nvim",
      requires = 'echasnovski/mini.icons',
    },

    -- Completion
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-omni',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
      },
      opts = function(_, opts)
        local cmp = require("cmp")
        opts.experimental = {
          native_menu = false,
          ghost_text = false,
        }
        opts.completion = { autocomplete = false }
        opts.mapping = cmp.mapping({
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        })
        opts.sources = {
          { name = 'omni' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'path' },
          { name = 'buffer' },
        }
      end,
    },

    -- colorschemes
    { "rebelot/kanagawa.nvim" },
    { 'Mofiqul/vscode.nvim' },

    { 
      'junegunn/fzf', 
      run = './install --bin', 
    },

    {'lewis6991/gitsigns.nvim'},

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "kanagawa" } },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false},
})
