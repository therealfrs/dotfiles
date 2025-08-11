-- " vim: set fdm=marker fenc=utf-8 sw=2 ts=2:

local which_key_map = {}
local after_load = {}
local map = vim.api.nvim_set_keymap

vim.cmd [[
exe 'source' expand('~/.config/nvim/basics.vim')
exe 'source' expand('~/.config/nvim/google.vim')
]]

map('n', 'Y', 'y$', {noremap = true})

--  yank in visual mode doesn't not jump the cursor.
map('v', 'Y', 'ygv<Esc>', {noremap = true})

vim.o.background = "dark"

-- Placeholder to be customised by local configs.
-- function _G.local_plugins(use) end
-- vim.s.local_init=expand("~/.config/nvim/") . join(split(hostname(), '\.')[0:1],".") . ".vim"

vim.o.mouse = "a"

-- local home_dir = os.getenv("HOME")
-- package.path = home_dir .. "/.config/nvim/after/plugin/?.lua;" .. package.path

-- for key in keys(g:after_load)
-- call vim.g:after_load[key]()
-- endfor

vim.cmd [[
	augroup highlight_yank
			autocmd!
			au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=100}
	augroup END
]]

-- defines makeprg as ninja if there is a BUIlD.gn in current directory
function set_ninja_make()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(vim.fn.glob(cwd .. "/BUILD.gn"))
  then
    vim.o.makeprg = 'autoninja -C'
  end
end
set_ninja_make()

vim.api.nvim_create_augroup("NinjaMake", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPre", {
  pattern = "make",
  group = "NinjaMake",
  callback = function()
    -- old_efm_for_ninja = nil
    -- Check if we are using the ninja makeprg
    if string.find(vim.o.makeprg, "autoninja -C") then
      -- Get the arguments passed to :make (e.g., "out/Default")
      local args = vim.fn.expand("<afile>")
      -- The first argument to make is the build directory.
      local build_dir = vim.fn.split(args, " ")[1]
      -- Check that the directory actually exists
      if build_dir and build_dir ~= "" and vim.fn.isdirectory(build_dir) == 1 then
        vim.opt.errorformat:prepend("%D" .. vim.fn.getcwd() .. "/" .. build_dir)
      end
    end
  end,
})


-- disable lsp highlight
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
end

require('config.lazy')
