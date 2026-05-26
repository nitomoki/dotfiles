require("toggleterm").setup {
    on_open = function()
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
