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

    keys = {
        -- Diagnostics
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle focus=true<CR>",
            desc = "Trouble: workspace diagnostics",
        },
        {
            "<leader>xd",
            "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<CR>",
            desc = "Trouble: buffer diagnostics",
        },

        -- Current file structure
        {
            "<leader>xs",
            "<cmd>Trouble symbols toggle focus=true<CR>",
            desc = "Trouble: document symbols",
        },

        -- References only
        {
            "gr",
            "<cmd>Trouble lsp_references toggle focus=true<CR>",
            desc = "Trouble: references",
        },
    },
}
