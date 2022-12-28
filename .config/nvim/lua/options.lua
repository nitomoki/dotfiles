local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g

-- o.matchpairs = [[(:),{:},[:],<:>,=:;,（:）,「:」,『:』【:】]]
b.autoindent = true
b.smartindent = true
b.syntax = [[ON]]
g.loaded_matchparen = 1
g.mapleader = " "
g.tex_conceal = [[]]
g.tex_flavor = [[latex]]
o.autochdir = false
o.cmdheight = 0
o.compatible = false
o.completeopt = "menuone,noinsert,noselect"
o.completeopt = [[menu]]
o.encoding = [[utf-8]]
o.expandtab = true
o.helplang = [[ja,en]]
o.hidden = true
o.history = 10000
o.hlsearch = false
o.ignorecase = true
o.incsearch = true
o.laststatus = 0
o.listchars = [[tab:>-,trail:-,eol:↴,extends:>,precedes:<,nbsp:%]]
o.matchpairs = [[(:),{:},[:],<:>,=:;]]
o.matchtime = 1
o.shiftwidth = 4
o.shortmess = o.shortmess .. "c"
o.showcmd = true
o.showmatch = true
o.showmode = 0
o.showtabline = 1
o.smartcase = true
o.signcolumn = "yes"
o.statusline = [[%#DiffChange# ]]
o.tabstop = 4
o.termguicolors = true
o.virtualedit = [[block]]
o.wildmenu = true
o.wildmode = [[list:full]]
w.cursorline = true
w.list = true
w.number = false

local handle = io.popen [[which zsh]]
local result = handle and handle:read "*a"
local _ = handle and handle:close()
if result and result ~= "" then
    o.shell = result:gsub("^%s*(.-)%s*$", "%1")
end
