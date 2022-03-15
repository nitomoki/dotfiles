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

function M.merge_highlight(newhi, ...)
    local sources_cmd = {...}
    local command = "highlight " .. newhi
    for _, source_cmd in ipairs(sources_cmd) do
        --local source = vim.fn.execute("highlight " .. source_cmd)
        local source = vim.fn.execute("highlight " .. source_cmd)
        local resolved = source:gsub('^%W%S+%s+xxx%s', "")
        command = command .. " " .. resolved
    end

    return command
end


_G.utils = M
return M
