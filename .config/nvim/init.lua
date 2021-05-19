initlua = "init lua"
local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

local utils = require('utils')

g.mapleader = ' '

o.hlsearch = false
w.cursorline = true
w.number = true
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
b.tabstop = 4
b.expandtab = true
o.showtabline = 2
b.shiftwidth = 4
b.autoindent = true
b.smartindent = true
o.smartcase = true
w.list = true
o.listchars = [[tab:>-,trail:-,eol:?,extends:>,precedes:<,nbsp:%]]
o.hidden = true
o.history = 50
o.virtualedit = [[block]]
o.encoding = [[utf-8]]
o.autochdir = true
o.compatible = false
o.completeopt = [[menu]]
g.tex_flavor = [[latex]]
g.tex_conceal = [[]]
b.syntax = [[ON]]

utils.map('n', '<leader>k', [[:bnext<CR>]], {noremap = true})
utils.map('n', '<leader>j', [[:bprev<CR>]], {noremap = true})
utils.map('n', '<leader>w', [[:w!<CR>]], {noremap = true})
utils.map('t', '<C-[>', [[<C-\><C-n>]], {noremap = true})
utils.map('n', 'j', [[gj]], {noremap = true})
utils.map('n', 'k', [[gk]], {noremap = true})
utils.map('n', 'gj', 'j', {noremap = true})
utils.map('n', 'gk', 'k', {noremap = true})
utils.map('n', 'q', '<Nop>', {noremap = true})
utils.map('i', '<UP>', '<Nop>', {noremap = true})
utils.map('i', '<DOWN>', '<Nop>', {noremap = true})
utils.map('i', '<RIGHT>', '<Nop>', {noremap = true})
utils.map('i', '<LEFT>', '<Nop>', {noremap = true})
utils.map('i', '<S-UP>', '<Nop>', {noremap = true})
utils.map('i', '<S-DOWN>', '<Nop>', {noremap = true})
utils.map('i', '<S-RIGHT>', '<Nop>', {noremap = true})
utils.map('i', '<S-LEFT>', '<Nop>', {noremap = true})
utils.map('n', 'Q', 'q', {noremap = true})

function _G.smart_tab()
    return fn.pumvisible() == 1 and [[\<C-n>]] or [[\<tab>]]
end
utils.map('i', '<tab>', 'v:lua.smart_tab()', {expr = true, noremap = true})
utils.map('i', '<S-tab>', 'v:lua.smart_tab()', {expr = true, noremap = true})

-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', , {noremap = true})
-- utils.map('', '', [[]], {})
--
utils.create_augroup({
    {'BufNewFile,BufRead', '*.launch', 'set', 'filetype=xml'}
}, 'BufE')

if fn.has('unix') then
    local vim_home = fn.expand('~/.cacheaaa')
elseif fn.has('win32') then
    local vim_home = fn.expand('$HOME/vimfiles')
end

local vim_home = fn.expand('~/.cacheaaa')

local dein_dir = vim_home .. '/dein'
local config_dir = fn.expand('~/.config/nvim')
local dein_repo_dir = dein_dir .. [[/repos/github.com/Shougo/dein.vim]]

if string.match(o.rtp, '/dein.vim') == nil then
    if fn.isdirectory(dein_repo_dir) == nil then
        os.execute([[git clone https://github.com/Shougo/dein.vim ]] .. dein_repo_dir)
    end
    utils.add_rtp(fn.fnamemodify(dein_repo_dir, ':p'))
end

print(dein_dir)
--print(fn['dein#load_state'](dein_dir) == 1)
if fn['dein#load_state'](dein_dir) == 1 then
    fn['dein#begin'](dein_dir)
    cmd([[call dein#load_toml(']] .. config_dir .. [[/dein.toml', {"lazy":0})]])
    cmd([[call dein#load_toml(']] .. config_dir .. [[/dein_lazy.toml', {"lazy":1})]])
    fn['dein#remote_plugins']()
    fn['dein#end']()
    fn['dein#save_state']()
end


fn['dein#add']('tomasr/molokai')
cmd('colorscheme molokai')

if fn['dein#check_install']() ==1 then
    fn['dein#install']()
end

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {
      'lua',
      'ruby',
      'toml',
      'c_sharp',
      'vue',
    }
  },
  ensure_installed = 'all',
}



function _G.GetBufByte()
    local byte = fn.line2byte(fn.line('$') +1)
    if byte == -1 then
        return 0
    else
        return byte - 1
    end
end

function _G.Term()
    if fn['dein#check_install']('neoterm') == 0 then
        cmd('Tnew')
    else
        cmd('terminal')
    end
end

function _G.CloseBuf()
    if fn.len(fn.filter(fn.range(1,fn.bufnr('$')), 'buflisted(v:val)')) == 1 then
        cmd('q')
    else
        local filetype = cmd('echo &filetype')
        if filetype == 'neoterm' or filetype == 'terminal' then
            cmd('bn')
        else
            cmd('bd')
        end
    end
end

utils.create_augroup({
    {'VimEnter', '*', 'if @%==""&&v:GetBufByte()==0', '| call v:Term()', '| endif'},
    {'BufLeave', '*', 'if exists("b:term_title")&&exists("b:terminal_job_pid")', '| execute ":file term" . b:terminal_job_pid . "/" . b:term_title'}
},'Term')

utils.map('n', '<leader>q', ':up!<CR>:call v:CloseBuf()<CR>', {noremap = true})


utils.create_augroup({
    {'BufNewFile,BufRead', '*.toml', 'call v:Syntax_range_dein()'}
}, 'TomlSyntax')

function _G.Syntax_range_dein()
    local start = [[^\s*hook_\%(add\|source\|post_source\|post_update\)\s*=\s*%s]]
    fn['SyntaxRange#Include'](fn.printf(start,"'''"), "'''", 'vim', '')
    fn['SyntaxRange#Include'](fn.printf(start,'"""'), '"""', 'vim', '')
end

vim.api.nvim_exec(
[[
fu Tapi_lcd(buf, cwd) abort
    if has('nvim')
        exe 'lcd '..a:cwd
        return ''
    endif
    let winid = bufwinid(a:buf)
    if winid == -1 || empty(a:cwd)
        return
    endif
    call win_execute(winid, 'lcd '..a:cwd)
endfu
]]
,false)












