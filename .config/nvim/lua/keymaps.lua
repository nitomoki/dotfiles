local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')

utils.map('n', '<leader>k', [[:bnext<CR>]], {silent = true, noremap = true})
utils.map('n', '<leader>j', [[:bprev<CR>]], {silent = true, noremap = true})
utils.map('n', '<leader>w', [[:w!<CR>]], {noremap = true})
utils.map('n', '<leader>f', [[:e .<CR>]], {noremap = true})
utils.map('t', '<C-[>', [[<C-\><C-n>]], {noremap = true})
utils.map('n', 'j', [[gj]], {silent = true, noremap = true})
utils.map('n', 'k', [[gk]], {silent = true, noremap = true})
utils.map('n', 'gj', 'j', {silent = true, noremap = true})
utils.map('n', 'gk', 'k', {silent = true, noremap = true})
utils.map('n', 'q', '<Nop>', {silent = true, noremap = true})
utils.map('i', '<UP>', '<Nop>', {noremap = true})
utils.map('i', '<DOWN>', '<Nop>', {noremap = true})
utils.map('i', '<RIGHT>', '<Nop>', {noremap = true})
utils.map('i', '<LEFT>', '<Nop>', {noremap = true})
utils.map('i', '<S-UP>', '<Nop>', {noremap = true})
utils.map('i', '<S-DOWN>', '<Nop>', {noremap = true})
utils.map('i', '<S-RIGHT>', '<Nop>', {noremap = true})
utils.map('i', '<S-LEFT>', '<Nop>', {noremap = true})
utils.map('n', 'Q', 'q', {noremap = true})
utils.map('n', '<F5>', [[:QuickRun<CR>]], {noremap = true})

local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function _G.smart_tab()
    return fn.pumvisible() == 1 and t'<C-n>' or t'<tab>'
end


utils.map('i', '<tab>', 'v:lua.smart_tab()', {expr = true, noremap = true})
utils.map('i', '<S-tab>', 'v:lua.smart_tab()', {expr = true, noremap = true})
