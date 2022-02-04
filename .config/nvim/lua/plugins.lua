--local o = vim.o
--local w = vim.wo
--local b = vim.bo
--local g = vim.g
local fn = vim.fn
--local cmd = vim.cmd

local packer_repo_dir = fn.expand([[~/.local/share/nvim/site/pack/packer/start/packer.nvim]])

if fn.isdirectory(packer_repo_dir) == 0 then
    os.execute([[git clone https://github.com/wbthomason/packer.nvim ]] .. packer_repo_dir)
end
local packer = require'packer'
local utils = require'utils'
-- AutoPackerCompile
-- utils.create_augroup({
--     {'BufWritePost', 'plugins.lua', 'PackerCompile'}
-- }, 'AutoPackerCompile')
utils.create_augroup({
    {'BufWritePost', '*/.config/nvim/*/*.lua', 'PackerCompile'}
}, 'AutoPackerCompile')

return require'packer'.startup(function(use)
    packer.use_rocks({
    })
    use {'wbthomason/packer.nvim'}
    use {'Yggdroot/indentLine'}
    use {'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'config.treesitter'
            end
    }
    use 'kyazdani42/nvim-web-devicons'
    use {'sainnhe/sonokai'}
    use {'ulwlu/elly.vim'}
    use {'williamboman/nvim-lsp-installer'}
    use {'neovim/nvim-lspconfig', config = function() require'config.lsp' end}
    use {'hrsh7th/nvim-cmp',
        requires = {{'hrsh7th/cmp-buffer'},
                    {'hrsh7th/cmp-nvim-lua'},
                    {'hrsh7th/cmp-nvim-lsp'},
                    {'hrsh7th/cmp-calc'},
                    {'hrsh7th/cmp-path'},
                    {'hrsh7th/cmp-cmdline'},
                    {'L3MON4D3/LuaSnip'},
                    {'saadparwaiz1/cmp_luasnip'}
                },
        config = function()
            require'config.cmp'
        end
    }
    use {"akinsho/nvim-toggleterm.lua",
        config = function ()
            require"toggleterm".setup{}
            require'config.term'.setup()
        end
    }
    use {'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}, {'nvim-telescope/telescope-file-browser.nvim'},},
        config = function ()
            require'config.telescope'
        end
    }
    use {'tjdevries/express_line.nvim',
        requires = {{'nvim-lua/plenary.nvim'}},
        config = function ()
            require'config.el'
        end
    }
    use {'AckslD/nvim-neoclip.lua',
        config = function()
            require'neoclip'.setup()
        end
    }




end)

