local utils = require'utils'
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
utils.map('n', '<leader>fb',
    [[:Telescope file_browser<CR>]],
    {silent = true, noremap = true}
    )
utils.map('n', '<leader>ff',
    [[<cmd>lua require'telescope.builtin'.find_files({find_command = {'rg', '--hidden', '-g', '!.git', '--files'}})<CR>]],
    {silent = true, noremap = true}
    )
utils.map('n', '<leader>b',
    [[<cmd>lua require'telescope.builtin'.file_browser({hidden = true})<CR>]],
    {silent = true, noremap = true}
    )
utils.map('n', '<leader>fh',
    [[:Telescope help_tags<CR>]],
    {silent = true, noremap = true}
    )
utils.map('n', '<leader>fo',
    [[:Telescope oldfiles<CR>]],
    {silent = true, noremap = true}
    )
