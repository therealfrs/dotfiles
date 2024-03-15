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
