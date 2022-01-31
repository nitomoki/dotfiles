local utils = require'utils'
-- local keymap = require'vim.keymap'
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
    },
    extensions = {
        file_browser = {
            theme = 'ivy',
            mappings = {
                ["i"] = {
                },
                ["n"] ={
                },
            },
        },
    },
}

local opts = {noremap = true, silent = true}
local builtin = require'telescope.builtin'
local extensions = require'telescope'.extensions
-- keymap.set('n', '<leader>b', builtin.buffers, opts)
-- keymap.set('n', '<leader>g', builtin.live_grep{vimgrep_arguments={ 'rg', '--color=never', '--no-heading', '--line-number', '--column', '--smart-case', '-u' }}, opts)
-- keymap.set('n', '<leader>fb', extensions.file_browser.file_browser({hidden=true}), opts)

utils.map('n', '<leader>b',
    [[<cmd>lua require'telescope.builtin'.buffers()<CR>]]
    )
utils.map('n', '<leader>g',
    [[<cmd>lua require'telescope.builtin'.live_grep{vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--line-number', '--column', '--smart-case', '-u' }}<CR>]]
    )
utils.map('n', '<leader>fb',
    [[<cmd>lua require'telescope'.extensions.file_browser.file_browser({hidden = true})<CR>]]
    )
utils.map('n', '<leader>ff',
    [[<cmd>lua require'telescope.builtin'.find_files({find_command = {'rg', '--hidden', '-g', '!.git', '--files'}})<CR>]]
    )
utils.map('n', '<leader>fh',
    [[:Telescope help_tags<CR>]]
    )
utils.map('n', '<leader>fo',
    [[:Telescope oldfiles<CR>]]
    )
utils.map('n', '<leader>fr',
    [[<cmd>lua require'telescope.builtin'.registers()<CR>]]
    )
