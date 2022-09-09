local id_cmdwin = vim.api.nvim_create_augroup("CmdWin", {})
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    group = id_cmdwin,
    pattern = "[:/?=]",
    callback = function()
        vim.wo.number = false
        vim.wo.signcolumn = "no"
    end,
})
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    group = id_cmdwin,
    pattern = ":",
    callback = function()
        vim.cmd [[g/^qa\?!\?$/d]]
        vim.cmd [[g/^wq\?a\?!\?$/d]]
    end,
})
vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    group = id_cmdwin,
    pattern = "*",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("n", "<C-q>", function()
            vim.cmd [[q]]
        end, { noremap = true, buffer = bufnr })
    end,
})

local id_ros_filetype = vim.api.nvim_create_augroup("ROS_filetype", {})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = id_ros_filetype,
    pattern = { "*.launch", "*.xacro" },
    callback = function()
        vim.bo.filetype = "xml"
    end,
})
