require("neoclip").setup()

vim.keymap.set("n", "<leader>c", require("telescope").extensions.neoclip.default, { silent = true, noremap = true })
