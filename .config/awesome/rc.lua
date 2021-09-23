-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require'awful.autofocus'
require'awful.hotkeys_popup.keys'

require'main.error-handling'.setup()
require'main.autostart'.setup()
require'main.layouts'.setup()
require'main.menu'.setup()
require'main.mouse'.setup()

local beautiful = require'beautiful'
beautiful.init(string.format("%s/.config/awesome/themes/theme.lua", os.getenv("HOME")))
beautiful.font = "DejaVu Sans 14"

require'main.screen'.setup()

local globalkeys = require'keybinds.globalkeys'
root.keys(globalkeys)
require'main.rules'.setup()
require'main.signals'.setup()

