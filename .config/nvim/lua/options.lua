vim.g.loaded_matchparen = 1
vim.g.mapleader = " "
vim.g.tex_conceal = ""
vim.g.tex_flavor = "latex"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.mouse = nil
vim.opt.autochdir = false
vim.opt.autoindent = true
vim.opt.cmdheight = 0
vim.opt.compatible = false
vim.opt.completeopt = "menu"
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.cursorline = true
vim.opt.encoding = "utf-8"
vim.opt.expandtab = true
vim.opt.helplang = { "ja", "en" }
vim.opt.hidden = true
vim.opt.history = 10000
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.laststatus = 0
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "-", eol = "↴", extends = ">", precedes = "<", nbsp = "%" }
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>", "=:;" }
vim.opt.matchpairs:append { "（:）", "「:」", "『:』", "【:】" }
vim.opt.matchtime = 1
vim.opt.number = false
vim.opt.shiftwidth = 4
vim.opt.shortmess:append "c"
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.showtabline = 1
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.statusline = "%#DiffChange# "
vim.opt.swapfile = false
vim.opt.syntax = "ON"
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.virtualedit = "block"
vim.opt.wildmenu = true
vim.opt.wildmode = { "list:full" }

if vim.fn.executable "zsh" == 1 then
    vim.opt.shell = "zsh"
end
-- local handle = io.popen [[which zsh]]
-- local result = handle and handle:read "*a"
-- local _ = handle and handle:close()
-- if result and result ~= "" then
--     vim.opt.shell = result:gsub("^%s*(.-)%s*$", "%1")
-- end
