local nvim_lsp = require('lspconfig')
local configs = require('lspconfig.configs')
configs.clangd = {
 default_config = {
   -- cmd = {'/google/bin/releases/cider/ciderlsp/ciderlsp', '--tooltag=nvim-lsp' , '--noforward_sync_responses'};
   cmd = {'/usr/bin/clangd', '--header-insertion=never'};
   filetypes = {'c', 'cpp', 'java', 'go', 'python', 'bzl'};
   root_dir = nvim_lsp.util.root_pattern('compile_commands.json');
   settings = {};
 }
}

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
  -- }
    -- See `:help vim.lsp.*` for documentation on any of the below functions.
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

    -- vim.api.nvim_command("augroup LSP")
    -- vim.api.nvim_command("autocmd!")
    -- if client.resolved_capabilities.document_highlight then
    --   vim.api.nvim_command("autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()")
    --   vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
    --   vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.util.buf_clear_references()")
    -- end
    -- vim.api.nvim_command("augroup END")
  -- end
}
