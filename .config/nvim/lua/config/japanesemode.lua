local M = {}

local check_ibus = function()
    vim.cmd('call system("type ibus")')
    return vim.v.shell_error
end

local check_fcitx = function()
    vim.cmd('call system("type fcitx")')
    return vim.v.shell_error
end

function M.setup()
    local on_command = ""
    local off_command =""
    local japanese_mode = false
    local japanese_mode_str = 'OFF'
    PLUGIN_JPMODE = true

    if check_ibus() == 0 then
        on_command  = "ibus engine 'xkb:jp::jpn'"
        off_command = "ibus engine 'mozc-jp'"
    elseif check_fcitx() == 0 then
        on_command  = "fcitx-remote -o"
        off_command = "fcitx-remote -c"
    else
        return -1
    end

    function PLUGIN_JPMODE_CURRENT()
        return japanese_mode
    end

    function _G.JapaneseInsertOff()
        if japanese_mode == true then
            os.execute(off_command)
        end
    end

    function _G.JapaneseInsertOn()
        if japanese_mode == true then
            os.execute(on_command)
        end
    end

    function ToggleJapaneseMode(vim_mode)
        japanese_mode = not(japanese_mode)
        japanese_mode_str = (japanese_mode) and 'ON' or 'OFF'
        if (vim_mode == 'i') then
            if japanese_mode then
                os.execute(on_command)
            else
                os.execute(off_command)
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
