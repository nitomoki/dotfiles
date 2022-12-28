local null_ls = require("null-ls")
vim.notify("require null-ls setting")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.completion.spell,
    },
})
-- local registry = require "mason-registry"
-- local mason_path = [[$HOME/.local/share/nvim/mason/bin/]]
-- 
-- local check_command = function(arg)
--     local cmd = ("call system('type %s')"):format(arg)
--     vim.cmd(cmd)
--     return vim.v.shell_error == 0
-- end
-- 
-- local set_formatting = function(lang, pattern, cmd, arg)
--     local format_callback = function()
--         -- vim.cmd(([[silent exec "!%s%s %s %s"]]):format(mason_path, cmd, arg, vim.fn.expand "%:p"))
--         vim.cmd(([[silent exec "!%s %s %s"]]):format(cmd, arg, vim.fn.expand "%:p"))
--         vim.cmd "edit!"
--         vim.cmd "write"
--     end
-- 
--     local augroup_name = lang .. "Formatter"
--     local setting_callback = function()
--         vim.api.nvim_create_autocmd("BufWritePost", {
--             group = vim.api.nvim_create_augroup(augroup_name, { clear = true }),
--             pattern = pattern,
--             callback = format_callback,
--         })
--     end
-- 
--     local setting_once_callback = function()
--         if registry.is_installed(cmd) or check_command(cmd) then
--             setting_callback()
--         else
--             vim.api.nvim_del_augroup_by_name(augroup_name)
--         end
--     end
-- 
--     vim.api.nvim_create_autocmd("BufEnter", {
--         group = vim.api.nvim_create_augroup(augroup_name, { clear = true }),
--         pattern = pattern,
--         callback = setting_once_callback,
--     })
-- end
-- 
-- -- lua
-- set_formatting("Lua", { "*.lua" }, "stylua", "--search-parent-directories")
-- 
-- -- c++
-- set_formatting("CPP", { "*.cpp", "*.hpp" }, "clang-format", "-i -style='{IndentWidth: 4, ColumnLimit: 100}'")
