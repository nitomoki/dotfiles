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
    --    use { "Yggdroot/indentLine" }
    use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("indent_blankline").setup {
                show_current_context = true,
                show_current_context_start = true,
            }
        end,
    }
    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            require("nvim-treesitter.install").update { with_sunc = true }
        end,
        config = function()
            require "config.treesitter"
        end,
    }
    use "kyazdani42/nvim-web-devicons"
    use { "sainnhe/sonokai" }
    use { "ulwlu/elly.vim" }
    --use { "williamboman/nvim-lsp-installer" }
    use {
        "neovim/nvim-lspconfig",
        requires = {
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            require "config.lsp"
            require "config.formatter"
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
            require "config.luasnip"
            require "config.cmp"
        end,
    }
    --use {
    --    "ckipp01/stylua-nvim",
    --    run = "cargo install stylua",
    --    config = function()
    --        require("stylua-nvim").setup {
    --            config_file = "~/.config/stylua/stylua.toml",
    --        }
    --    end,
    --}
    --use {"akinsho/nvim-toggleterm.lua",
    use {
        "akinsho/toggleterm.nvim",
        config = function()
            require "config.term"
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
            require "config.telescope"
        end,
    }
    use {
        "tjdevries/express_line.nvim",
        requires = { { "nvim-lua/plenary.nvim" }, { "lewis6991/gitsigns.nvim" } },
        config = function()
            require "config.el"
            require("gitsigns").setup()
        end,
    }
    use {
        "AckslD/nvim-neoclip.lua",
        requires = {
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require "config.neoclip"
        end,
    }
    -- use {
    --     "~/nvim_plugins/JPmode.nvim",
    --     config = function()
    --         require("JPmode").setup {}
    --     end,
    -- }
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
