local o = vim.o
local w = vim.wo
local b = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local utils = require('utils')

local packer_repo_dir = fn.expand([[~/.local/share/nvim/site/pack/packer/start/packer.nvim]])

if fn.isdirectory(packer_repo_dir) == 0 then
    os.execute([[git clone https://github.com/wbthomason/packer.nvim ]] .. packer_repo_dir)
end

return require'packer'.startup(function()
    use 'wbthomason/packer.nvim'
    use 'Yggdroot/indentLine'
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use {'hoob3rt/lualine.nvim', config = function() require'nitom.lualineconfig' end}
    use 'kyazdani42/nvim-web-devicons'
    use {'kassio/neoterm', config = function() require'nitom.nitomterm'.setup() end}
    use {'sainnhe/sonokai', config = cmd('colorscheme sonokai')}
    use {'neovim/nvim-lspconfig',
        opt = true, 
        event = 'BufRead',
        config = 
            function() 
                require'lspconfig'.ccls.setup{}
                require'lspconfig'.texlab.setup{}
                require'lspconfig'.omnisharp.setup{}
                require'lspconfig'.pyls.setup{}
            end
    }

end)
