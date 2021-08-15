--local o = vim.o
--local w = vim.wo
--local b = vim.bo
--local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

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
                require'nvim-treesitter'.setup{
                    highlight = {
                      enable = true,
                      disable = {
                        'ruby',
                        'toml',
                        'c_sharp',
                        'vue',
                        }
                    }
                }
            end
    }
    use {'hoob3rt/lualine.nvim', config = function() require'nitom.lualine' end}
    use 'kyazdani42/nvim-web-devicons'
    use {'sainnhe/sonokai', config = cmd('colorscheme sonokai')}
    use {'neovim/nvim-lspconfig', config = function() require'nitom.lsp' end}
    use {'nvim-lua/completion-nvim',
        config = function()
            vim.cmd[[autocmd BufEnter * lua require'completion'.on_attach()]]
        end
    }
    use {'norcalli/snippets.nvim',
        config = function ()
            require'snippets'.use_suggested_mappings()
            require'utils'.map('i', '<C-k>', [[<cmd>lua return require'snippets'.expand_or_advance(1)<CR>]],
                {noremap = true, silent = true})
            require'utils'.map('i', '<C-j>', [[<cmd>lua return require'snippets'.advance_snippet(-1)<CR>]],
                {noremap = true, silent = true})
        end
    }
    use {"akinsho/nvim-toggleterm.lua",
        config = function ()
            require"toggleterm".setup{}
            require'nitom.term'.setup()
        end
    }
    use {'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
        config = function()
            require('telescope').setup{
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
            --require'nitom.viminit'.telescope_fb()
            require'utils'.map('n', '<leader>fb', [[:Telescope file_browser<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>ff', [[<cmd>lua require'telescope.builtin'.find_files({find_command = {'rg', '--hidden', '-g', '!.git', '--files'}})<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>b', [[:Telescope buffers<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>fh', [[:Telescope help_tags<CR>]], {silent = true, noremap = true})
            require'utils'.map('n', '<leader>fo', [[:Telescope oldfiles<CR>]], {silent = true, noremap = true})
        end
    }
end)


