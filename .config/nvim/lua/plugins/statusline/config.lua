local vi_mode = require "plugins.statusline.components.ViMode"
local file_components = require "plugins.statusline.components.FileComponents"
local git = require "plugins.statusline.components.Git"
local diagnostics = require "plugins.statusline.components.Diagnostics"
local lsp = require "plugins.statusline.components.Lsp"
local cwd = require "plugins.statusline.components.WorkingDirectory"
-- local project_info = require "heirline-bitburner-ram"  -- disabled for performance

local colors = require "tokyonight.colors"

local Sep = { provider = "   " }

-- UTF-8 + unix 以外の場合のみ表示
local FileEncoding = {
    condition = function()
        local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
        local fmt = vim.bo.fileformat
        return enc ~= "utf-8" or fmt ~= "unix"
    end,
    provider = function()
        local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
        local fmt = vim.bo.fileformat
        local parts = {}
        if enc ~= "utf-8" then table.insert(parts, enc:upper()) end
        if fmt ~= "unix" then table.insert(parts, fmt:upper()) end
        return table.concat(parts, " ")
    end,
    hl = { fg = "yellow", bold = true },
}

local FileType = {
    provider = function()
        return vim.bo.filetype
    end,
    hl = { fg = "cyan" },
}

local Cursor = {
    provider = "%l:%c",
}

local ScrollPercent = {
    provider = "%3p%%",
}

local StatusLine = {
    -- Left
    { vi_mode },
    Sep,
    { git.GitBranch },
    { git.GitDiff },
    Sep,
    { file_components.FileNameBlock },
    -- Center
    { provider = "%=" },
    -- Right
    { FileType },
    Sep,
    -- { project_info.ProjectInfo },  -- disabled for performance
    Sep,
    { diagnostics.Diagnostics },
    Sep,
    { FileEncoding },
    Sep,
    { cwd.WorkDir },
    Sep,
    { Cursor },
    Sep,
    { ScrollPercent },
    Sep,
    { lsp.lsp_active },
}

require("heirline").setup {
    statusline = StatusLine,
    opts = {
        colors = colors,
    },
}
