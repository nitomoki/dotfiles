local vi_mode = require "plugins.statusline.components.ViMode"
local file_components = require "plugins.statusline.components.FileComponents"
local lsp = require "plugins.statusline.components.Lsp"
local cwd = require "plugins.statusline.components.WorkingDirectory"

local colors = require "tokyonight.colors"

local StatusLine = {
    { vi_mode },
    { provider = "   " },
    { file_components.FileNameBlock },
    { provider = "%=" },
    { cwd.WorkDir },
    { provider = "   " },
    { lsp.lsp_active },
}

require("heirline").setup {
    statusline = StatusLine,
    opts = {
        colors = colors,
    },
}
