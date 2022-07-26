local isInstalled = function(arg)
    local cmd = ("call system('type %s')"):format(arg)
    vim.cmd(cmd)
    return (vim.v.shell_error == 0)
end

local setting = function(filetype, cmd)
    local callback = function()
        vim.cmd(([[silent exec "%s"]]):format(cmd))
        vim.cmd "edit!"
        vim.cmd "write"
    end
    return function()
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup(("%sFormatter"):format(filetype), { clear = true }),
            pattern = ("*.%s"):format(filetype),
            callback = callback,
        })
    end
end

-- lua
local lua_setting =
    setting("lua", ([[!$HOME/.cargo/bin/stylua --search-parent-directories %s]]):format(vim.fn.expand "%:p"))

if not isInstalled "stylua" then
    vim.fn.jobstart([[cargo install stylua]], {
        on_exit = lua_setting,
    })
else
    lua_setting()
end
