-- Minimal init.lua for testing
local std_data = vim.fn.stdpath("data")
local cwd = vim.fn.getcwd()

-- Add plenary and the current config directory to the runtimepath
vim.opt.rtp:append(std_data .. "/lazy/plenary.nvim")
vim.opt.rtp:append(cwd)

-- Ensure we can load our utilities
package.path = cwd .. "/lua/?.lua;" .. package.path

-- Enable filetype detection
vim.cmd("filetype plugin indent on")
