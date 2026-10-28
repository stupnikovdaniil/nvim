-- ~/.config/nvim/lua/plugins/undotree.lua
return {
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
        keys = require("config.keys").plugin("undotree"),
		init = function()
			vim.g.undotree_WindowLayout = 2 -- боковая панель справа (1 = вертикально, 2 = горизонтально)
			vim.g.undotree_SplitWidth = 35 -- ширина панели
			vim.g.undotree_DiffpanelHeight = 10 -- высота diff-панели
			vim.g.undotree_SetFocusWhenToggle = 1

		end,
	},
}
