-- ~/.config/nvim/lua/plugins/colors.lua

local function ColorMyPencils(color)
    color = color or "rose-pine-moon"

    vim.o.termguicolors = true
    vim.o.background = "dark"

    local ok, err = pcall(vim.cmd.colorscheme, color)
    if not ok then
        vim.notify(
            "Colorscheme not found: " .. color .. "\n" .. err,
            vim.log.levels.ERROR
        )
        return
    end

    -- Прозрачность только для основного редактора
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    -- ВАЖНО:
    -- NormalNC не трогаем, чтобы у неактивных окон/зон оставался фон.
    -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

    -- Границы floating windows
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "WinSeparator" })

    -- Для nvim-notify/noice, чтобы не было:
    -- Highlight group 'NotifyBackground' has no background
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#232136" })
end

local function setup_theme_command()
    vim.api.nvim_create_user_command("ColorUse", function(opts)
        ColorMyPencils(opts.args)
    end, {
        nargs = 1,
        force = true,
        complete = function()
            return { "rose-pine-moon", "tokyonight", "gruvbox" }
        end,
    })
end

return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        lazy = false,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                disable_background = true,
                styles = {
                    italic = false,
                },
            })

            ColorMyPencils("rose-pine-moon")
            setup_theme_command()
            require("config.keys").apply("themes")
        end,
    },

    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 900,
        opts = {
            style = "storm",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
        },
    },

    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 800,
        opts = {
            terminal_colors = true,
            italic = {
                comments = false,
                keywords = false,
            },
            transparent_mode = false,
        },
    },
}
