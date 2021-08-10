local M = {}
local utils = require('utils')
local fn = vim.fn
local cmd = vim.cmd

function M.setup()
    function _G.GetBufByte()
        local byte = fn.line2byte(fn.line('$') +1)
        if byte == -1 then
            return 0
        else
            return byte - 1
        end
    end

    --local neoterm_valid = fn['dein#check_install']('neoterm')
    local neoterm_valid = 0
    function _G.Term()
        if neoterm_valid == 0 then
            cmd('Tnew')
        else
            cmd('terminal')
        end
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

    utils.create_augroup({
        {'VimEnter', '*', 'if @%==""&&v:lua.GetBufByte()==0', '| call v:lua.Term()', '| endif'},
        --{'BufLeave', '*', 'if exists("b:term_title")&&exists("b:terminal_job_pid")', '| execute ":file term" . b:terminal_job_pid . "/" . b:term_title'}
    },'Term')

    utils.map('n', '<leader>q', ':up!<CR>:call v:lua.CloseBuf()<CR>', {noremap = true, silent = true})
    if neoterm_valid == 0 then
        utils.map('n', '<leader>t', ':Tnew<CR>', {noremap = true, silent = true})
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
