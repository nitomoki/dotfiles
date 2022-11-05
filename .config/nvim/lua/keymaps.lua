local keymap = vim.keymap
local opts = { silent = true, noremap = true }

local map_tables = {
    {
        modes = { "n" },
        maps = {
            { "<leader>w", [[:wall!<CR>]] },
            { "<leader>.", [[:lcd %:h<CR>]] },
            { "j", "gj" },
            { "k", "gk" },
            { "gj", "j" },
            { "gk", "k" },
            { "q", "<Nop>" },
            { "Q", "q" },
        },
    },
    {
        modes = { "i" },
        maps = {
            { "<UP>", "<Nop>" },
            { "<DOWN>", "<Nop>" },
            { "<RIGHT>", "<Nop>" },
            { "<LEFT>", "<Nop>" },
            { "<S-UP>", "<Nop>" },
            { "<S-DOWN>", "<Nop>" },
            { "<S-RIGHT>", "<Nop>" },
            { "<S-LEFT>", "<Nop>" },
        },
    },
    {
        modes = { "i", "c" },
        maps = {
            { "<M-¥>", "¥" },
            { "¥", "\\" },
        },
    },
    {
        modes = { "t" },
        maps = {
            { "<C-[>", [[<C-\><C-n>]] },
        },
    },
    {
        modes = { "n", "o", "v" },
        maps = {
            { "f<M-¥>", "f¥" },
            { "F<M-¥>", "F¥" },
            { "f¥", "f\\" },
            { "F¥", "F\\" },
        },
    },
}

for _, table in pairs(map_tables) do
    for _, mode in pairs(table.modes) do
        for _, map in pairs(table.maps) do
            keymap.set(mode, map[1], map[2], opts)
        end
    end
end
