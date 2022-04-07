local utils = require "utils"

utils.create_augroup({
    { "BufNewFile,BufRead", "*.launch", "set", "filetype=xml" },
}, "BufE")

utils.create_augroup({
    { "VimEnter,ColorScheme", "*", "hi", "Normal", "ctermbg=none", "guibg=none" },
    { "VimEnter,ColorScheme", "*", "hi", "NonText", "ctermbg=none", "guibg=none" },
    { "VimEnter,ColorScheme", "*", "hi", "LineNr", "ctermbg=none", "guibg=none" },
    { "VimEnter,ColorScheme", "*", "hi", "Folded", "ctermbg=none", "guibg=none" },
    { "VimEnter,ColorScheme", "*", "hi", "EndOfBuffer", "ctermbg=none", "guibg=none" },
}, "TransparentBG")
