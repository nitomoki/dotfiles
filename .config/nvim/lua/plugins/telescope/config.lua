local actions = require "telescope.actions"
local z_utils = require "telescope._extensions.zoxide.utils"

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<C-t>"] = actions.close,
                -- ["<C-q>"] = actions.close,
                ["<C-c>"] = actions.close,
            },
            n = {
                ["<C-t>"] = actions.close,
                -- ["<C-q>"] = actions.close,
                ["<C-c>"] = actions.close,
            },
        },
        find_command = {
            "/usr/local/bin/rg",
            "--hidden",
            "-g",
            "!.git",
            "--files",
        },
        vimgrep_arguments = {
            "/usr/local/bin/rg",
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
        zoxide = {
            prompt_title = "[ Walking on the shoulders of TJ ]",
            mappings = {
                default = {
                    after_action = function(selection)
                        print("Update to (" .. selection.z_score .. ") " .. selection.path)
                    end,
                },
                ["<C-s>"] = {
                    before_action = function(selection)
                        print "before C-s"
                    end,
                    action = function(selection)
                        vim.cmd("edit " .. selection.path)
                    end,
                },
                -- Opens the selected entry in a new split
                ["<C-q>"] = { action = z_utils.create_basic_command "split" },
            },
        },
    },
}

require("telescope").load_extension "zoxide"
