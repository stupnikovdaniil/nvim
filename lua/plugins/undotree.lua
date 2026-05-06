-- ~/.config/nvim/lua/plugins/undotree.lua
return {
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree panel" },
		},
		init = function()
			vim.g.undotree_WindowLayout = 2 -- боковая панель справа (1 = вертикально, 2 = горизонтально)
			vim.g.undotree_SplitWidth = 35 -- ширина панели
			vim.g.undotree_DiffpanelHeight = 10 -- высота diff-панели
			vim.g.undotree_SetFocusWhenToggle = 1
			-- включаем постоянную историю undo между сессиями
			if vim.fn.has("persistent_undo") == 1 then
				local dir = vim.fn.expand("~/.local/share/nvim/undodir")
				if vim.fn.isdirectory(dir) == 0 then
					vim.fn.mkdir(dir, "p", 0700)
				end
				vim.opt.undodir = dir
				vim.opt.undofile = true
			end
		end,
	},
}
