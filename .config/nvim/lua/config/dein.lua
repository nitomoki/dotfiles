local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')


if fn.has('unix') == 1 then
    local vim_home = fn.expand('~/.cacheaaa')
elseif fn.has('win32') == 1 then
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

--print(dein_dir)
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
