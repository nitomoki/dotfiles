return {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    -- module = "telescope",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        -- "nvim-telescope/telescope-file-browser.nvim",
        -- "jvgrootveld/telescope-zoxide",
    },
    init = function()
        require "plugins.telescope.keymap"
    end,
    config = function()
        require "plugins.telescope.config"
    end,
}
