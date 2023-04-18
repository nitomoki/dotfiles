local M = {}
local handle = nil
local msg_table = {}
local isProcessing = false

M.run = function()
    local cwd = vim.fn.getcwd()
    if isProcessing then
        vim.notify("Now make is processing on " .. cwd .. ". Wait for seconds.")
        return
    end

    isProcessing = true
    -- local stdout = vim.loop.new_pipe()
    -- local stderr = vim.loop.new_pipe()
    vim.notify("Start acync make on " .. cwd .. ".")
    handle = vim.loop.spawn("make", {
        args = { "-C", cwd },
        -- stdio = { nil, stdout, stderr },
        stdio = { nil, nil, nil },
    }, function()
        vim.notify "Make is done."
        -- stdout:close()
        -- stderr:close()
        handle:close()
        isProcessing = false
    end)

    -- if handle then
    --     vim.loop.read_start(stdout, function(err, data)
    --         if not err and data then
    --             table.insert(msg_table, data)
    --         end
    --     end)
    --     vim.loop.read_start(stderr, function(err, data)
    --         if not err and data then
    --             table.insert(msg_table, data)
    --             -- vim.notify(vim.inspect(vim.split(data, "\r?\n")))
    --             -- vim.notify(data)
    --         end
    --         if err then
    --             table.insert(msg_table, err)
    --             -- vim.notify(vim.inspect(vim.split(err, "\r?\n")))
    --             -- vim.notify(err)
    --         end
    --     end)
    -- end
end

return M
