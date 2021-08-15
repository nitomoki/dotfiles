local M = {}
local cmd = vim.cmd

function M.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end
    cmd('augroup END')
end


function M.add_rtp(path)
    local rtp = vim.o.rtp
    vim.o.rtp = rtp .. ',' .. path
end

function M.map(mode, keys, action, options)
    if options == nil then
        options = {noremap = true, silent = true}
    end
    vim.api.nvim_set_keymap(mode, keys, action, options)
end

function M.map_lua(mode, keys, action, options)
    if options == nil then
        options = {noremap = true, silent = true}
    end
    vim.api.nvim_set_keymap(mode, keys, "<cmd>lua " .. action .. "<CR>", options)
end


function M.map_buf(mode, keys, action, options, buf_nr)
    if options == nil then
        options = {}
    end
    local buf = buf_nr or 0
    vim.api.nvim_set_keymap(buf, mode, keys, "<cmd>lua " .. action .. "<CR>", options)
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
