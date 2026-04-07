local conditions = require "heirline.conditions"

local M = {}

M.GitBranch = {
    condition = conditions.is_git_repo,
    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict or {}
    end,
    provider = function(self)
        return " " .. (self.status_dict.head or "")
    end,
    hl = { fg = "orange", bold = true },
}

M.GitDiff = {
    condition = function()
        return conditions.is_git_repo() and vim.b.gitsigns_status_dict ~= nil
    end,
    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict or {}
        self.added = self.status_dict.added or 0
        self.changed = self.status_dict.changed or 0
        self.removed = self.status_dict.removed or 0
        self.has_changes = self.added > 0 or self.changed > 0 or self.removed > 0
    end,
    {
        provider = function(self)
            if self.added > 0 then return " +" .. self.added end
        end,
        hl = { fg = "green" },
    },
    {
        provider = function(self)
            if self.changed > 0 then return " ~" .. self.changed end
        end,
        hl = { fg = "cyan" },
    },
    {
        provider = function(self)
            if self.removed > 0 then return " -" .. self.removed end
        end,
        hl = { fg = "red" },
    },
}

return M
