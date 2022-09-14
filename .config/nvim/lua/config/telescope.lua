local actions = require "telescope.actions"
require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-t>"] = actions.close,
                ["<C-q>"] = actions.close,
                ["<C-c>"] = actions.close,
            },
            n = {
                ["<C-t>"] = actions.close,
                ["<C-q>"] = actions.close,
                ["<C-c>"] = actions.close,
            },
        },
        find_command = {
            "rg",
            "--hidden",
            "-g",
            "!.git",
            "--files",
        },
        vimgrep_arguments = {
            "rg",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "-u",
        },
    },
    pickers = {
        help_tags = {
            mappings = {
                ["i"] = {
                    ["<CR>"] = actions.select_vertical,
                },
            },
        },
    },
    extensions = {
        file_browser = {
            theme = "ivy",
            mappings = {
                ["i"] = {
                    ["<C-h>"] = false,
                },
                ["n"] = {
                    ["<C-t>"] = false,
                },
            },
            hidden = true,
        },
    },
}

local opts = { noremap = true, silent = true }
local builtin = require "telescope.builtin"
local extensions = require("telescope").extensions
vim.keymap.set("n", "<leader>b", builtin.buffers, opts)
vim.keymap.set("n", "<leader>j", function()
    builtin.buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
end, opts)
vim.keymap.set("n", "<leader>k", function()
    builtin.buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
end, opts)
vim.keymap.set("n", "<leader>r", builtin.resume, opts)
vim.keymap.set("n", "<leader>fb", extensions.file_browser.file_browser, opts)
vim.keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, opts)
vim.keymap.set("n", "<leader>ff", builtin.find_files, opts)
vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts)
vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts)
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, opts)
