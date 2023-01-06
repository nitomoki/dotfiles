local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>hi", function()
    require("telescope.builtin").highlights()
end, { noremap = true })

vim.keymap.set("n", "<leader>b", function()
    require("telescope.builtin").buffers()
end, opts)

vim.keymap.set("n", "<leader>j", function()
    require("telescope.builtin").buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
end, opts)

vim.keymap.set("n", "<leader>k", function()
    require("telescope.builtin").buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
end, opts)

vim.keymap.set("n", "<leader>r", function()
    require("telescope.builtin").resume()
end, opts)

vim.keymap.set("n", "<leader>fb", function()
    require("telescope").extensions.file_browser.file_browser()
end, opts)

vim.keymap.set("n", "<leader>fc", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
end, opts)

vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
end, opts)

vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").live_grep()
end, opts)

vim.keymap.set("n", "<leader>fh", function()
    require("telescope.builtin").help_tags()
end, opts)

vim.keymap.set("n", "<leader>fo", function()
    require("telescope.builtin").oldfiles()
end, opts)

vim.keymap.set("n", "<leader>cd", function()
    require("telescope").extensions.zoxide.list()
end, opts)
