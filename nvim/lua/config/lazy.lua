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
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate'
  },
  {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        local lualine = require('lualine')
        lualine.setup{
          options = {
            theme = 'alabaster',
            component_separators = '',
            section_separators = ''
          },
          sections = {
            lualine_a = {
              {
                'filename',
                path = 3,
              },
            },
            lualine_b = {},
            lualine_c = {},

            lualine_x = {},
            lualine_y = {'filetype'},
            lualine_z = {'location'},
          },
          tabline = {},
          extensions = {},
        }
      end
    },

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
        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the buffer
        local on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end

        -- local lspconfig = require('lspconfig')
        -- Define the configuration for the clangd server
        vim.lsp.config.clangd = {
            cmd = { 'clangd', '--background-index' },
            root_markers = { 'compile_commands.json', 'compile_flags.txt' },
            filetypes = { 'c', 'cpp' },
            on_attach = on_attach
        }
        vim.lsp.config.pylsp = {
          on_attach = on_attach
        }
        vim.lsp.config.taplo = {
          default_config = {
            cmd = { 'taplo', 'lsp', 'stdio' },
            filetypes = { 'toml' },
            root_markers = {'.git'},
            single_file_support = true,
          },
          docs = {
            description = [[
            https://taplo.tamasfe.dev/cli/usage/language-server.html

            Language server for Taplo, a TOML toolkit.

            `taplo-cli` can be installed via `cargo`:
            ```sh
            cargo install --features lsp --locked taplo-cli
            ```
            ]],
          },
        }
        -- " Set the TS config for the LSP
        vim.lsp.config.tsserver =  {
          -- " Make sure this is on your path
          cmd = {'typescript-language-server', '--stdio'},
          filetypes = { 'typescript' },
          -- " This is a hint to tell nvim to find your project root from a file within the tree
          root_dir = vim.fs.root(0, {'package.json', '.git'}),
          on_attach = on_attach,
          -- capabilities = capabilities,
          -- " optional settings = {...} go here, refer to language server code: https://github.com/typescript-language-server/typescript-language-server/blob/5c483349b7b4b6f79d523f8f4d854cbc5cec7ecd/src/ts-protocol.ts#L379
        },

        -- Enable the clangd language server
        vim.lsp.enable({ 'clangd' })
        vim.lsp.enable({ 'pylsp' })
        vim.lsp.enable({ 'taplo' })
        vim.lsp.enable({ 'gopls' })
        vim.lsp.enable({ 'tsserver' })

      end,
    },

    -- Smart key mapping
    {
      "folke/which-key.nvim",
      requires = 'echasnovski/mini.icons',
    },

    -- Completion
    {
      'saghen/blink.cmp',
      dependencies = { 'rafamadriz/friendly-snippets' },
      version = '1.*',
      opts = {
        keymap = { preset = 'default' },
        appearance = {
          nerd_font_variant = 'mono'
        },

        completion = { menu = { auto_show = false } },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      },
      opts_extend = { "sources.default" }
    },

    -- colorschemes
    { "rebelot/kanagawa.nvim" },
    { 'Mofiqul/vscode.nvim' },
    { "p00f/alabaster.nvim" },

    { 
      'junegunn/fzf', 
      run = './install --bin', 
    },

    {'lewis6991/gitsigns.nvim'},

    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 
        'nvim-mini/mini.icons', version = '*' 
      },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "alabaster" } },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false},
})
