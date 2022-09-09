require("toggleterm").setup {
    on_open = function()
        vim.cmd [[startinsert!]]
        local bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("n", "<C-q>", function()
            vim.cmd [[bd!]]
        end, { noremap = true, buffer = bufnr })
        vim.keymap.set("t", "<C-q>", function()
            vim.cmd [[bd!]]
        end, { noremap = true, buffer = bufnr })
    end,
}

local Terminal = require("toggleterm.terminal").Terminal
local python_repl = Terminal:new {
    auto_scroll = true,
    close_on_exit = true,
    direction = "vertical",
    cmd = "python3",
}

local closeBuf = function()
    local buflisted = function(bufnr)
        return vim.fn.buflisted(bufnr) == 1
    end

    local bufs = vim.fn.len(vim.tbl_filter(buflisted, vim.fn.range(1, vim.fn.bufnr "$")))
    if bufs == 1 then
        vim.cmd "q"
    else
        vim.cmd "bd"
        if bufs == 2 and vim.fn.line2byte(vim.fn.line "$") == -1 then
            vim.cmd "q"
        end
    end
end

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<C-t>", [[:ToggleTerm direction=float<CR>]], opts)
vim.keymap.set("t", "<C-t>", [[<C-\><C-n>:ToggleTerm<CR>]], opts)
vim.keymap.set("n", "<C-q>", closeBuf, opts)
vim.keymap.set("t", "<C-q>", closeBuf, opts)

vim.keymap.set("n", "<leader><leader>p", function()
    python_repl:toggle()
end, opts)
