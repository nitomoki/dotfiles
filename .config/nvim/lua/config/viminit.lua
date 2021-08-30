local M = {}
local utils = require('utils')


function M.telescope_fb()
    utils.create_augroup({{'VimEnter', '*', 'lua require"nitom.viminit".VimInit_TelescopeFB()'}},'VimInit_TelescopeFB')
end
function M.VimInit_TelescopeFB()
    if utils.get_buf_byte() == 0 then
        require'telescope.builtin'.file_browser()
    end
end

return M



