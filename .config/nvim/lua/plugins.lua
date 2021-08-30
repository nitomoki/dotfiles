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

return require'packer'.startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'Yggdroot/indentLine'
    use {'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'config.treesitter'
            end
    }
    use {'hoob3rt/lualine.nvim',
        config = function() require'config.lualine' end
    }
    use 'kyazdani42/nvim-web-devicons'
    use {'sainnhe/sonokai'}
    use {'neovim/nvim-lspconfig', config = function() require'config.lsp' end}
    use {'hrsh7th/vim-vsnip'}
    use {'hrsh7th/nvim-cmp',
        requires = {{'hrsh7th/cmp-buffer'},
                    {'hrsh7th/cmp-nvim-lua'},
                    {'hrsh7th/cmp-nvim-lsp'},
                    {'hrsh7th/cmp-calc'},
                    {'hrsh7th/cmp-path'},
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
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
        config = function()
            require'telescope'.setup{
                defaults = {
                    vimgrep_arguments = {
                        'rg',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                        '-u'
                    },
                }
            }
            require'utils'.map('n', '<leader>fb', [[:Telescope file_browser<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>ff', [[<cmd>lua require'telescope.builtin'.find_files({find_command = {'rg', '--hidden', '-g', '!.git', '--files'}})<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>b', [[:Telescope buffers<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>fh', [[:Telescope help_tags<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>fo', [[:Telescope oldfiles<CR>]], {silent = true, noremap = true})
        end
    }
    use {'AckslD/nvim-neoclip.lua',
        config = function()
            require'neoclip'.setup()
        end
    }



end)


