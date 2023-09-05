local conditions = require "heirline.conditions"
local utils = require "heirline.utils"

local M = {}

M.WorkDir = {
    provider = function()
        local icon = (vim.fn.haslocaldir(0) == 1 and "l " or "") .. "  "
        local cwd = vim.fn.getcwd(0)
        cwd = vim.fn.fnamemodify(cwd, ":~")
        if not conditions.width_percent_below(#cwd, 0.25) then
            cwd = vim.fn.pathshorten(cwd)
        end
        local trail = cwd:sub(-1) == "/" and "" or "/"
        return icon .. cwd .. trail
    end,
    hl = { fg = utils.get_highlight("Directory").fg },
}

return M
