local packer_repo_dir = vim.fn.expand [[~/.local/share/nvim/site/pack/packer/start/packer.nvim]]

if vim.fn.isdirectory(packer_repo_dir) == 0 then
    os.execute([[git clone https://github.com/wbthomason/packer.nvim ]] .. packer_repo_dir)
    vim.cmd [[packadd packer.nvim]]
end
-- AutoPackerCompile
local id_apc = vim.api.nvim_create_augroup("AutoPackerCompile", {})
vim.api.nvim_create_autocmd("BufWritePost", {
    group = id_apc,
    pattern = "*/.config/nvim/*/*.lua",
    command = "PackerCompile",
})

return require("packer").startup(function(use)
    use { "wbthomason/packer.nvim" }
    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            require("nvim-treesitter.install").update { with_sunc = true }
        end,
        config = function()
            require "plugins.config.treesitter"
        end,
    }
    use {
        "nvim-treesitter/playground",
        config = function()
            vim.keymap.set("n", "<leader>h", "<CMD>TSHighlightCapturesUnderCursor<CR>", { noremap = true })
        end,
    }
    use "kyazdani42/nvim-web-devicons"
    use {
        "neovim/nvim-lspconfig",
        requires = {
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            require "plugins.config.lsp"
            require "plugins.config.formatter"
        end,
    }
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-nvim-lua" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-calc" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-cmdline" },
            { "L3MON4D3/LuaSnip" },
            { "saadparwaiz1/cmp_luasnip" },
            { "onsails/lspkind.nvim" },
        },
        config = function()
            require "plugins.config.luasnip"
            require "plugins.config.cmp"
        end,
    }
    use {
        "akinsho/toggleterm.nvim",
        config = function()
            require "plugins.config.term"
        end,
    }
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-file-browser.nvim" },
        },
        config = function()
            require "plugins.config.telescope"
            vim.keymap.set("n", "<leader>sh", require("telescope.builtin").highlights, { noremap = true })
        end,
    }
    use {
        "AckslD/nvim-neoclip.lua",
        requires = {
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require "plugins.config.neoclip"
        end,
    }
    use {
        "nitomoki/JPmode.nvim",
        --"~/NeovimPlugins/JPmode.nvim",
        config = function()
            require("JPmode").setup {
                on_command = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
                off_command = "/usr/local/bin/swim use com.apple.keylayout.ABC",
                keymap = {
                    i = {
                        toggle = "<C-]>",
                    },
                    n = {
                        off = "<C-]>",
                    },
                },
            }
        end,
    }
    use {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    }
    use {
        "goolord/alpha-nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("alpha").setup(require("alpha.themes.startify").config)
        end,
    }
end)
