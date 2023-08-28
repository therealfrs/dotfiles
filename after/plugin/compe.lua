local map = require('utils').map

vim.g.loaded_compe_treesitter = true
vim.g.loaded_compe_snippets_nvim = true
vim.g.loaded_compe_spell = true
vim.g.loaded_compe_tags = true
vim.g.loaded_compe_ultisnips = true
vim.g.loaded_compe_vim_lsc = true
vim.g.loaded_compe_vim_lsp = true

vim.g.compe = {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 2;
  auto_preselect = false;
  allow_prefix_unmatch = false;

  source = {
    path = true;
    buffer = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = {};
  };
}

local opts = {noremap = true, silent = true, expr = true}
map('i', '<c-space>', [[compe#complete()]], opts)
map('i', '<cr>', [[compe#confirm('<cr>')]], opts)
map('i', '<c-e>', [[compe#close('<c-e>')]], opts)
