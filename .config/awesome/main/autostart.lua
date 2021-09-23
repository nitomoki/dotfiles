local awful = require'awful'

local M = {}

M.setup = function ()
    -- }}}

    -- {{{ Autostart windowless processes

    -- This function will run once every time Awesome is started
    local cmds = {
        "urxvtd",
        "unclutter -root",
    }

    for _, cmd in ipairs(cmds) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end


    -- This function implements the XDG autostart specification
    --[[
    awful.spawn.with_shell(
        'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
        'xrdb -merge <<< "awesome.started:true";' ..
        -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
        'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
    )
    --]]
end

return M
