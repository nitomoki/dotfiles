local M = {}
local id_bg_opacity = vim.api.nvim_create_augroup("BG_Opacity", {})

local set_opacity = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, "NonText", { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, "Folded", { bg = "none", ctermbg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none", ctermbg = "none" })
end

M.setup = function()
    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        group = id_bg_opacity,
        pattern = "*",
        callback = set_opacity,
    })
    set_opacity()
end

return M
