return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            opts = {
                background_colour = "#000000",
            },
        },
    },
    opts = {
        cmdline = {
            enabled = true,
            view = "cmdline_popup",
        },

        views = {
            cmdline_popup = {
                position = {
                    row = "33%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
                border = {
                    style = "rounded",
                },
            },
        },

        popupmenu = {
            enabled = true,
            backend = "nui",
        },

        messages = {
            enabled = true,
        },

        presets = {
            bottom_search = false,
            command_palette = false,
            long_message_to_split = true,
            inc_rename = false,
        },
    },
}
