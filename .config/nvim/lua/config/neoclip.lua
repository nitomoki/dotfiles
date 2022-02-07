require'neoclip'.setup()


vim.keymap.set('n', '<leader>fc', require'telescope'.extensions.neoclip.default, {silent = true, noremap = true})
