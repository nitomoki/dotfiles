local M = {}

function M.create_augroup(autocmds, name)
    vim.cmd('augroup ' .. name)
    vim.cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        vim.cmd('autocmd ' .. table.concat(autocmd, ' '))
    end
    vim.cmd('augroup END')
end


function M.is_plugin_installed(plugin)
    return not (vim.fn.globpath(vim.o.rtp, 'pack/*/*/' .. plugin, 1) == '')
end


function M.get_buf_byte()
    local byte = vim.fn.line2byte(vim.fn.line('$') +1)
    if byte == -1 then
        return 0
    else
        return byte - 1
    end
end


_G.utils = M
return M
