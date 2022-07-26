local actions = require "telescope.actions"
require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-t>"] = actions.close,
                ["<C-q>"] = actions.close,
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

local s_opts = { noremap = true, silent = true }
local keymap = vim.keymap
local builtin = require "telescope.builtin"
local extensions = require("telescope").extensions
keymap.set("n", "<leader>b", builtin.buffers, s_opts)
keymap.set("n", "<leader>g", builtin.live_grep, s_opts)
keymap.set("n", "<leader>r", builtin.resume, s_opts)
keymap.set("n", "<leader>fb", extensions.file_browser.file_browser, s_opts)
keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, s_opts)
keymap.set("n", "<leader>ff", builtin.find_files, s_opts)
keymap.set("n", "<leader>fh", builtin.help_tags, s_opts)
keymap.set("n", "<leader>fo", builtin.oldfiles, s_opts)
keymap.set("n", "<leader>fr", builtin.registers, s_opts)
