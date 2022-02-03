local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
-- local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')

vim.opt.termguicolors = true

g.mapleader = ' '

o.hlsearch = false
w.cursorline = true
w.number = false
o.showcmd = true
o.showmatch = true
o.matchtime = 1
g.loaded_matchparen = 1
o.matchpairs = [[(:),{:},[:],<:>,=:;]]
o.helplang = [[ja,en]]
o.laststatus = 2
o.statusline = [[%F%r%h%=]]
o.incsearch = true
o.wildmenu = true
o.wildmode = [[list:full]]
o.ignorecase = true
--b.expandtab = true
--b.tabstop = 4
--b.shiftwidth = 4
cmd('set expandtab')
cmd('set tabstop=4')
cmd('set shiftwidth=4')
o.showtabline = 1
o.showmode = 0
b.autoindent = true
b.smartindent = true
o.smartcase = true
w.list = true
o.listchars = [[tab:>-,trail:-,eol:?,extends:>,precedes:<,nbsp:%]]
o.hidden = true
o.history = 50
o.virtualedit = [[block]]
o.encoding = [[utf-8]]
o.autochdir = false
o.compatible = false
o.completeopt = [[menu]]
g.tex_flavor = [[latex]]
g.tex_conceal = [[]]
b.syntax = [[ON]]
vim.cmd[[set completeopt=menuone,noinsert,noselect]]
vim.cmd[[set shortmess+=c]]

-- netrw
g.netrw_keepdir = 0

-- Command Line Window Options
utils.create_augroup({
    {'CmdwinEnter', '[:/?=]', 'setlocal', 'nonumber'},
    {'CmdwinEnter', '[:/?=]', 'setlocal', 'signcolumn=no'},
    {'CmdwinEnter', ':', [[g/^qa\?!\?$/d]]},
    {'CmdwinEnter', ':', [[g/^wq\?a\?!\?$/d]]},
},'CmdWin')




