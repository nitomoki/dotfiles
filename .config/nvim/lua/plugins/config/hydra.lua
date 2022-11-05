local Hydra = require "hydra"
local cmd = require("hydra.keymap-util").cmd
local pcmd = require("hydra.keymap-util").pcmd

local window_hint = [[
^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
^ ^ _k_ ^ ^  ^ ^ K ^ ^   ^   <C-k>   ^   _s_: horizontally 
_h_ ^ ^ _l_  H ^ ^ L   <C-h> <C-l>   _v_: vertically
^ ^ _j_ ^ ^  ^ ^ J ^ ^   ^   <C-j>   ^   _c_: close
focus^^^^^^  window^^^^^^  ^_=_: equalize^   z: maximize
^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
]]

Hydra {
    name = "Windows Manager",
    hint = window_hint,
    config = {
        invoke_on_body = true,
        hint = {
            border = "rounded",
            offset = -1,
        },
    },
    mode = "n",
    body = "<C-w>",
    heads = {
        { "h", "<C-w>h" },
        { "j", "<C-w>j" },
        { "k", pcmd("wincmd k", "E11", "close") },
        { "l", "<C-w>l" },

        { "=", "<C-w>=", { desc = "equalize" } },

        { "s", pcmd("split", "E36") },
        { "<C-s>", pcmd("split", "E36"), { desc = false } },
        { "v", pcmd("vsplit", "E36") },
        { "<C-v>", pcmd("vsplit", "E36"), { desc = false } },

        { "w", "<C-w>w", { exit = true, desc = false } },
        { "<C-w>", "<C-w>w", { exit = true, desc = false } },

        { "o", "<C-w>o", { exit = true, desc = "remain only" } },
        { "<C-o>", "<C-w>o", { exit = true, desc = false } },

        { "c", pcmd("close", "E444"), { desc = "close window" } },

        { "q", nil, { exit = true, desc = false } },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
}
