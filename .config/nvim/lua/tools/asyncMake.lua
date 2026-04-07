local M = {}
local isProcessing = false

M.run = function()
    local cwd = vim.fn.getcwd()
    if isProcessing then
        vim.notify("Now make is processing on " .. cwd .. ". Wait for seconds.")
        return
    end

    isProcessing = true
    vim.notify("Start async make on " .. cwd .. ".")
    vim.system({ "make", "-C", cwd }, {}, function(result)
        vim.schedule(function()
            isProcessing = false
            if result.code == 0 then
                vim.notify "Make is done."
            else
                vim.notify("Make failed (exit code: " .. result.code .. ")", vim.log.levels.ERROR)
            end
        end)
    end)
end

return M
