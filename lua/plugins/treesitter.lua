-- ~/.config/nvim/lua/plugins/colors.lua
local function ColorMyPencils(color)
  color = color or "rose-pine-moon"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
  -- rose-pine (основная)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        disable_background = true,
        styles = { italic = false },
      })
      ColorMyPencils("rose-pine-moon")
    end,
  },

  -- tokyonight (альтернатива)
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "storm",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  -- gruvbox (альтернатива)
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      terminal_colors = true,
      italic = {
        comments = false,
        keywords = false,
      },
      transparent_mode = true,
    },
  },
}

