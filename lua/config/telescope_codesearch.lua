-- Load codesearch extension in telescoe
require('telescope').load_extension('codesearch')

require('telescope').setup {
  defaults =  {
    -- The vertical layout strategy is good to handle long paths like those in
    -- google3 repos because you have nearly the full screen to display a file path.
    -- The caveat is that the preview area is smaller.
    layout_strategy = 'vertical',
    -- Common paths in google3 repos are collapsed following the example of Cider
    -- It is nice to keep this as a user config rather than part of
    -- telescope-codesearch because it can be reused by other telescope pickers.
    path_display = function(_, path)
      path = path:gsub("^/google/src/cloud/[^/]+/[^/]+/google3/", "google3/", 1)
      path = path:gsub("^google3/java/com/google/", "g3/j/c/g/", 1)
      path = path:gsub("^google3/javatests/com/google/", "g3/jt/c/g/", 1)
      path = path:gsub("^google3/third_party/", "g3/3rdp/", 1)
      path = path:gsub("^google3/", "g3/", 1)
      return path
    end,
  },
}

-- These custom mappings let you open telescope-codesearch quickly
vim.api.nvim_set_keymap('n', '<leader>ss',
  [[<cmd>lua require('telescope').extensions.codesearch.find_files{}<CR>]],
  { noremap = true, silent=true }
)
vim.api.nvim_set_keymap('n', '<leader>sd',
  [[<cmd>lua require('telescope').extensions.codesearch.find_query{}<CR>]],
  { noremap = true, silent=true }

