require("toggleterm").setup {
    size = function(term)
        local rate = 0.4
        if term.direction == "horizontal" then
            return vim.o.lines * rate
        elseif term.direction == "vertical" then
            return vim.o.columns * rate
        end
    end,
}

local closeBuf = function()
    if vim.fn.len(vim.fn.filter(vim.fn.range(1, vim.fn.bufnr "$"), "buflisted(v:val)")) == 1 then
        vim.cmd "q"
    else
        if vim.bo.filetype == "toggleterm" then
            vim.cmd "bd!"
        else
            vim.cmd "bd"
        end
    end
end

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<C-t>", [[:ToggleTerm direction=horizontal<CR>]], opts)
vim.keymap.set("t", "<C-t>", [[<C-\><C-n>:ToggleTerm<CR>]], opts)
vim.keymap.set("n", "<C-q>", closeBuf, opts)
vim.keymap.set("t", "<C-q>", closeBuf, opts)
