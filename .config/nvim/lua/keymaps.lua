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
            { "n", "nzzzv" },
            { "N", "Nzzzv" },
            -- {
            --     "<UP>",
            --     function()
            --         vim.notify "UP"
            --         vim.api.nvim_exec_autocmds("User", { pattern = "MyEventUP" })
            --     end,
            -- },
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
            { "t<M-¥>", "t¥" },
            { "T<M-¥>", "T¥" },
            { "t¥", "t\\" },
            { "T¥", "T\\" },
        },
    },
}

local opts = { silent = true, noremap = true }
for _, table in pairs(map_tables) do
    for _, map in pairs(table.maps) do
        vim.keymap.set(table.modes, map[1], map[2], opts)
    end
end
