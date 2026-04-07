local conditions = require "heirline.conditions"

local M = {}

M.Diagnostics = {
    condition = conditions.has_diagnostics,
    static = {
        icons = {
            error = " ",
            warn = " ",
            info = " ",
            hint = " ",
        },
    },
    init = function(self)
        local counts = vim.diagnostic.count(0)
        self.errors = counts[vim.diagnostic.severity.ERROR] or 0
        self.warnings = counts[vim.diagnostic.severity.WARN] or 0
        self.info = counts[vim.diagnostic.severity.INFO] or 0
        self.hints = counts[vim.diagnostic.severity.HINT] or 0
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
        provider = function(self)
            if self.errors > 0 then return self.icons.error .. self.errors .. " " end
        end,
        hl = { fg = "red" },
    },
    {
        provider = function(self)
            if self.warnings > 0 then return self.icons.warn .. self.warnings .. " " end
        end,
        hl = { fg = "yellow" },
    },
    {
        provider = function(self)
            if self.info > 0 then return self.icons.info .. self.info .. " " end
        end,
        hl = { fg = "cyan" },
    },
    {
        provider = function(self)
            if self.hints > 0 then return self.icons.hint .. self.hints end
        end,
        hl = { fg = "green" },
    },
}

return M
