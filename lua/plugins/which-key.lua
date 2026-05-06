return {
    "folke/which-key.nvim",
    event = "VeryLazy",

    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,

    opts = {
        preset = "modern",

        delay = function(ctx)
            -- Для leader показываем быстро, для остальных чуть спокойнее
            if ctx.keys:sub(1, 1) == " " then
                return 200
            end
            return 400
        end,

        win = {
            border = "rounded",
        },

        icons = {
            mappings = true,
        },

        spec = {
            { "<leader>c", group = "code/conform" },
            { "<leader>d", group = "diagnostics/delete/pins" },
            { "<leader>f", group = "find/telescope" },
            { "<leader>g", group = "git/fugitive" },
            { "<leader>p", group = "pinbar/paste" },
            { "<leader>s", group = "style/theme" },
            { "<leader>t", group = "tree/navigation" },
            { "<leader>w", group = "windows" },
            { "<leader>x", group = "trouble/diagnostics" },

            { "g",         group = "goto/LSP" },
            { "z",         group = "fold/tree" },
            { "[",         group = "previous" },
            { "]",         group = "next" },
        },
    },
}
