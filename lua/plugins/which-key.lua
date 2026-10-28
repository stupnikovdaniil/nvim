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

        spec = require("config.keys").groups,
    },
}
