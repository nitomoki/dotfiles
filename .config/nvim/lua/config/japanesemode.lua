local M = {}

function M.setup()
    vim.cmd('call system("type ibus")')
    if not(vim.v.shell_error == 0) then
        return -1
    end

    local japanese_mode = false
    local japanese_mode_str = 'OFF'
    PLUGIN_JPMODE = true
    function PLUGIN_JPMODE_CURRENT()
        return japanese_mode
    end

    function _G.JapaneseInsertOff()
        if japanese_mode == true then
            os.execute("ibus engine 'xkb:jp::jpn'")
        end
    end

    function _G.JapaneseInsertOn()
        if japanese_mode == true then
            os.execute("ibus engine 'mozc-jp'")
        end
    end

    function ToggleJapaneseMode(vim_mode)
        japanese_mode = not(japanese_mode)
        japanese_mode_str = (japanese_mode) and 'ON' or 'OFF'
        if (vim_mode == 'i') then
            if japanese_mode then
                os.execute("ibus engine 'mozc-jp'")
            else
                os.execute("ibus engine 'xkb:jp::jpn'")
            end
        end
        print("Japanese Mode: " .. japanese_mode_str)
        vim.cmd('redrawtabline')
    end

    utils.create_augroup({
        {'InsertLeave', '*', 'call v:lua.JapaneseInsertOff()'},
        {'InsertEnter', '*', 'call v:lua.JapaneseInsertOn()'}
    }, 'JapaneseMode')


    utils.map_lua('i', '<C-]>', 'ToggleJapaneseMode("i")', {noremap = true})
    utils.map_lua('n', '<C-]>', 'ToggleJapaneseMode("n")', {noremap = true})
end

return M
