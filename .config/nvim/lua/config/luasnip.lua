local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local ai = require "luasnip.nodes.absolute_indexer"
local fmt = require("luasnip.extras.fmt").fmt

local split = function(inputstr, sep)
    local res = {}
    if inputstr == "" then
        return { "" }
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(res, str)
    end
    return res
end

local same = function(index)
    return f(function(arg)
        return arg[1]
    end, { index })
end

local get_less = function(index)
    return f(function(arg)
        local parts = split(arg[1][1], ".")
        return parts[#parts]
    end, { index })
end

ls.add_snippets("all", {
    s("sametest", fmt([[example: {}, function: {}]], { i(1), same(1) })),
})
ls.add_snippets("lua", {
    s("req", fmt([[local {} = require "{}"]], { get_less(1), i(1) })),
})
