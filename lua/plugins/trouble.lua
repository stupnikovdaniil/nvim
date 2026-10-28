return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    opts = {
        focus = true,
        win = {
            position = "bottom",
            size = 12,
        },
        keys = {
            ["<esc>"] = "close",
        },
    },

    keys = require("config.keys").plugin("trouble"),
}
