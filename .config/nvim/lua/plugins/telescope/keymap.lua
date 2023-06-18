local opts = { noremap = true, silent = true }

---comment
---@param callback function
---@return function
local event_func = function(callback)
    return function()
        vim.api.nvim_exec_autocmds("User", { pattern = "TelescopeKeymap" })
        callback()
    end
end

vim.keymap.set(
    "n",
    "<leader>hi",
    event_func(function()
        require("telescope.builtin").highlights()
    end),
    { noremap = true }
)

vim.keymap.set(
    "n",
    "<leader>b",
    event_func(function()
        require("telescope.builtin").buffers()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>j",
    event_func(function()
        require("telescope.builtin").buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>k",
    event_func(function()
        require("telescope.builtin").buffers { initial_mode = "normal", ignore_current_buffer = true, sort_mru = true }
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>r",
    event_func(function()
        require("telescope.builtin").resume()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>fc",
    event_func(function()
        require("telescope.builtin").current_buffer_fuzzy_find()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>ff",
    event_func(function()
        require("telescope.builtin").find_files()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>fg",
    event_func(function()
        require("telescope.builtin").live_grep()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>fh",
    event_func(function()
        require("telescope.builtin").help_tags()
    end),
    opts
)

vim.keymap.set(
    "n",
    "<leader>fo",
    event_func(function()
        require("telescope.builtin").oldfiles()
    end),
    opts
)
