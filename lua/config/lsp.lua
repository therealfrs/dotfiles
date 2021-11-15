local lspconfig = require 'lspconfig'
local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'
local lsp_install = require 'lspinstall'

lsp_install.setup()

local on_attach_vim = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- require"lsp_signature".on_attach({bind = true, floating_window = false})

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

local kind_symbols = {
  Text = '',
  Method = 'Ƒ',
  Function = 'ƒ',
  Constructor = '',
  Variable = '',
  Class = '',
  Interface = 'ﰮ',
  Module = '',
  Property = '',
  Unit = '',
  Value = '',
  Enum = '了',
  Keyword = '',
  Snippet = '﬌',
  Color = '',
  File = '',
  Folder = '',
  EnumMember = '',
  Constant = '',
  Struct = ''
}
-- require('lspkind').init {symbol_map = kind_symbols}
require('lspkind').init {}

-- local servers = {ccls = true}
local servers = {ccls = true}

local ciderlsp = '/google/bin/releases/editor-devtools/ciderlsp'

if vim.loop.fs_stat(ciderlsp) ~= nil then

  configs.cider_lsp = {
    default_config = {
      cmd = {
        ciderlsp, '--tooltag=-nvim', '--noforward_sync_responses',
        '--hub_addr=blade:languageservices'
      },
      -- filetypes = {"typescript", "python"},
      filetypes = {"c", "cpp", "objc", "objcpp", "typescript", "python", "go", "java"},
      root_dir = util.root_pattern("WORKSPACE"),
      settings = {}
    }
  }
  -- configs.clangd = {
  --   default_config = {
  --     cmd = {'/usr/bin/clangd', '--background-index'},
  --     -- cmd = {'/usr/bin/clangd', '-index-file=/tmp/clangd_index.idx'},
  --     filetypes = {"c", "cpp", "objc", "objcpp"},
  --     root_dir = util.root_pattern("WORKSPACE"),
  --     settings = {}
  --   }
  -- }
  servers = {cider_lsp = true}
end

-- add all servers installed by lspinstall
for _, server in pairs(lsp_install.installed_servers()) do servers[server] =
    true end

for server, _ in pairs(servers) do
  lspconfig[server].setup {on_attach = on_attach_vim}
end
