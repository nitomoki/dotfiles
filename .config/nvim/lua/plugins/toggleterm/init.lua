return {
    "akinsho/toggleterm.nvim",
    lazy = true,
    cmd = "ToggleTerm",
    init = function()
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<C-t>", [[:ToggleTerm direction=float<CR>]], opts)
        vim.keymap.set("t", "<C-t>", [[<C-\><C-n>:ToggleTerm<CR>]], opts)
    end,
    config = function()
        require "plugins.toggleterm.config"
    end,
    dependencies = {
        {
            "chomosuke/term-edit.nvim",
            version = "1.*",
            config = function()
                require("term-edit").setup {
                    prompt_end = "❯ ",
                }
            end,
        },
    },
}
