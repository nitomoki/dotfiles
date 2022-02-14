local M = {}
local utils = require('utils')
local fn = vim.fn
local cmd = vim.cmd

function M.setup()

    utils.map('n', '<C-t>', ':call v:lua.Term()<CR>', {noremap = true, silent = true})
    utils.map('t', '<C-t>', [[<C-\><C-n>:call v:lua.Term()<CR>]], {noremap = true, silent = true})
    utils.map('n', '<c-q>', ':up!<CR>:call v:lua.CloseBuf()<CR>', {noremap = true, silent = true})
    local term_cmd = 'terminal'
    if utils.is_plugin_installed('toggleterm.nvim') then
        term_cmd = 'ToggleTerm direction=float'
    elseif utils.is_plugin_installed('neoterm') then
        term_cmd = 'Tnew'
    end

    function _G.Term()
        cmd(term_cmd)
    end

    function _G.CloseBuf()
        if fn.len(fn.filter(fn.range(1,fn.bufnr('$')), 'buflisted(v:val)')) == 1 then
            cmd('q')
        else
            local filetype = vim.bo.filetype
            local term_title = vim.b.term_title
            if filetype == 'neoterm' then
                if term_title == 'neoterm-1' then
                    cmd('bn')
                else
                    cmd('Tclose!')
                end
            elseif filetype == 'terminal' then
                cmd('bn')
            else
                cmd('bd')
            end
        end
    end

    vim.api.nvim_exec(
    [[
    fu! Tapi_lcd(buf, cwd) abort
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

end

return M
