local actions = require "telescope.actions"

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-t>"] = actions.close,
                ["<C-c>"] = actions.close,
            },
            n = {
                ["<C-t>"] = actions.close,
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
