local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g

o.termguicolors = true
g.mapleader = " "
o.hlsearch = false
w.cursorline = true
w.number = false
o.showcmd = true
o.showmatch = true
o.matchtime = 1
g.loaded_matchparen = 1
-- o.matchpairs = [[(:),{:},[:],<:>,=:;,（:）,「:」,『:』【:】]]
o.matchpairs = [[(:),{:},[:],<:>,=:;]]
o.helplang = [[ja,en]]
o.laststatus = 0
o.statusline = [[%#DiffChange# ]]
o.incsearch = true
o.wildmenu = true
o.wildmode = [[list:full]]
o.ignorecase = true
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.showtabline = 1
o.showmode = 0
b.autoindent = true
b.smartindent = true
o.smartcase = true
w.list = true
o.listchars = [[tab:>-,trail:-,eol:↴,extends:>,precedes:<,nbsp:%]]
o.hidden = true
o.history = 10000
o.virtualedit = [[block]]
o.encoding = [[utf-8]]
o.autochdir = false
o.compatible = false
o.completeopt = [[menu]]
g.tex_flavor = [[latex]]
g.tex_conceal = [[]]
b.syntax = [[ON]]
o.completeopt = "menuone,noinsert,noselect"
o.shortmess = o.shortmess .. "c"
o.cmdheight = 0

local handle = io.popen [[which zsh]]
local result = handle and handle:read "*a"
local _ = handle and handle:close()
if result and result ~= "" then
    o.shell = result:gsub("^%s*(.-)%s*$", "%1")
end
