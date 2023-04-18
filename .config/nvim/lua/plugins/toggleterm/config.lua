require("toggleterm").setup {
    on_open = function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("n", "<C-q>", function()
            vim.cmd [[bd!]]
        end, { noremap = true, buffer = bufnr })
        vim.keymap.set("t", "<C-q>", function()
            vim.cmd [[bd!]]
        end, { noremap = true, buffer = bufnr })
    end,
    start_in_insert = true,
    float_opts = {
        width = function()
            return vim.o.columns
        end,
        height = function()
            return vim.o.lines
        end,
    },
}
