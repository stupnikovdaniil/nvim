-- ~/.config/nvim/lua/plugins/lualine.lua
return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	opts = {
		options = {
			theme = "auto",
			icons_enabled = true,
			globalstatus = true, -- единая статус-строка снизу
			section_separators = "",
			component_separators = "",
			disabled_filetypes = {
				statusline = { "neo-tree", "alpha", "lazy", "Trouble", "toggleterm" },
				winbar = {},
			},
			refresh = { statusline = 200, tabline = 1000, winbar = 1000 },
		},

		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{ "branch", icon = "" },
				{ "diff" },
			},
			lualine_c = {
				{ "filename", path = 1, shorting_target = 40 }, -- относительный путь
				-- LSP: имя активных серверов + спиннер прогресса
				{ "lsp_status", icon = "", colored = true, show_name = true },
				-- Диагностика из встройки Neovim
				{ "diagnostics", sources = { "nvim_diagnostic" } },
			},
			lualine_x = {
				{ function()
                    return require("config.formatting").disabled() and "fmt:off" or "fmt:on"
                end },
                { "encoding" },
				{ "fileformat" },
				{ "filetype" },
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},

		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},

		-- Ничего лишнего сверху; при желании можно включить позже
		tabline = {},
		winbar = {},
		inactive_winbar = {},

		-- Спец-оформление для определённых плагинов
		extensions = { "neo-tree", "trouble", "toggleterm", "lazy", "fugitive", "mason", "quickfix" },
	},

	config = function(_, opts)
		require("lualine").setup(opts)
	end,
}
