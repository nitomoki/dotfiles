local builtin = require'el.builtin'
local extensions = require'el.extensions'
local subscribe = require'el.subscribe'
local sections = require'el.sections'
local lsp_statusline = require'el.plugins.lsp_status'


local generator = function()
    local el_segments = {
        segments = {},
        add = function(self, elm)
                table.insert(self.segments, elm)
                return self
            end,
        get = function(self)
                return self.segments
            end,
    }

    local getcwd = function()
        local cwd = "[" .. vim.fn.getcwd() .. "]"
        return cwd
    end

    return el_segments
        :add(extensions.mode)
        :add(" ")
        :add(builtin.shortened_file)
        :add(sections.collapse_builtin{" ", builtin.modified_flag,})
        :add(sections.split)
        :add(getcwd)
        --:add(sections.split)
        :add(lsp_statusline.segment)
        :add(lsp_statusline.current_function)
        :add(subscribe.buf_autocmd("el_git_status", "BufWritePost",
                function(window, buffer)
                    return extensions.git_changes(window, buffer)
                end
            )
        )
        :add("[")
        :add(builtin.line)
        :add(" : ")
        :add(builtin.column)
        :add("]")
        :add(sections.collapse_builtin{
                "[",
                builtin.help_list,
                builtin.readonly_list,
                "]"
            }
        )
        :add(builtin.filetype)
        :get()
end

require'el'.setup{
    generator = generator
}
