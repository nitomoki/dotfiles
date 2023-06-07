return {
    {
        "stevearc/oil.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("oil").setup {
                use_default_keymaps = false,
                keymaps = {
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.select",
                    ["<C-p>"] = "actions.preview",
                    ["<C-l>"] = "actions.refresh",
                    ["_"] = "actions.open_cwd",
                    ["g."] = "actions.toggle_hidden",
                    ["<C-c>"] = "actions.close",
                    ["q"] = "actions.close",
                    [".."] = "actions.parent",
                },
            }
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        lazy = true,
        event = "BufReadPost",
        config = function()
            require("colorizer").setup()
        end,
    },
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- require("alpha").setup(require("alpha.themes.dashboard").config)
            local alpha = require "alpha"
            local dashboard = require "alpha.themes.dashboard"

            -- Set header
            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
            }

            -- Set menu
            dashboard.section.buttons.val = {
                dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
                dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
                dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
            }

            -- Send config to alpha
            alpha.setup(dashboard.opts)

            -- Disable folding on alpha buffer
            vim.cmd [[
                autocmd FileType alpha setlocal nofoldenable
            ]]
        end,
    },
}
