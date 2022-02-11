local utils = require'utils'
local M = {}

local check_ibus = function()
    vim.cmd('call system("type ibus")')
    return vim.v.shell_error
end

local check_fcitx = function()
    vim.cmd('call system("type fcitx")')
    return vim.v.shell_error
end

local check_swim = function()
    vim.cmd('call system("type swim")')
    return vim.v.shell_error
end


M.PLUGIN_JPMODE = true
M.isJapaneseMode = false

function M.setup()
    local on_command = ""
    local off_command = ""
    --local isJapaneseMode = false
    local isJapaneseMode_str = 'OFF'
    PLUGIN_JPMODE = true

    if check_ibus() == 0 then
        on_command  = "ibus engine 'xkb:jp::jpn'"
        off_command = "ibus engine 'mozc-jp'"
    elseif check_fcitx() == 0 then
        on_command  = "fcitx-remote -o"
        off_command = "fcitx-remote -c"
    elseif check_swim() == 0 then
        on_command  = "swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"
        off_command = "swim use com.apple.keylayout.ABC"
    else
        return -1
    end


    M.JapaneseInsertOff = function()
        if M.isJapaneseMode  then
            os.execute(off_command)
        end
    end

    M.JapaneseInsertOn = function()
        if M.isJapaneseMode then
            os.execute(on_command)
        end
    end

    function ToggleJapaneseMode(vim_mode)
        M.isJapaneseMode = not(M.isJapaneseMode)
        isJapaneseMode_str = (M.isJapaneseMode) and 'ON' or 'OFF'
        if (vim_mode == 'i') then
            if M.isJapaneseMode then
                os.execute(on_command)
            else
                os.execute(off_command)
            end
        end
        print("Japanese Mode: " .. isJapaneseMode_str)
        vim.cmd('redrawtabline')
    end

    utils.create_augroup({
        {'InsertLeave', '*', [[lua require'config.japanesemode'.JapaneseInsertOff()]]},
        {'InsertEnter', '*', [[lua require'config.japanesemode'.JapaneseInsertOn()]]}
    }, 'JapaneseMode')

    local h_ToggleJapaneseMode_I = function()
        ToggleJapaneseMode("i")
    end

    local h_ToggleJapaneseMode_N = function()
        ToggleJapaneseMode("n")
    end

    vim.keymap.set('i', '<C-]>', h_ToggleJapaneseMode_I, {noremap = true})
    vim.keymap.set('n', '<C-]>', h_ToggleJapaneseMode_N, {noremap = true})
end

function M.PLUGIN_JPMODE_CURRENT()
    return M.isJapaneseMode
end

return M
