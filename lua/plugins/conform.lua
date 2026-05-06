-- ~/.config/nvim/lua/plugins/conform.lua
return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "ConformInfo", "Format", "FormatDisable", "FormatEnable" },

		opts = {
			-- автоформат при сохранении (sync для мелких, async для крупных)
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				local ok, st = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok and st and st.size and st.size > 512 * 1024 then
					return { async = true, lsp_format = "fallback", timeout_ms = 8000 }
				end
				return { async = false, lsp_format = "fallback", timeout_ms = 5000 }
			end,

			-- чем форматировать
			formatters_by_ft = {
				lua = { "stylua" },

				python = function(bufnr)
					local c = require("conform")
					if c.get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,

				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				json = { "json_repair", "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "mdformat" },

				go = { "gofumpt", "goimports" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				toml = { "taplo" },
				terraform = { "terraform_fmt" },
				hcl = { "terraform_fmt" },
				sql = { "sqlfluff" },
			},

			-- точечные настройки
			formatters = {
				sqlfluff = { prepend_args = { "--dialect", "postgres" } },
				shfmt = { prepend_args = { "-i", "2", "-ci" } },
				mdformat = { prepend_args = { "--number" } },
			},
		},

		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			-- gq / visual range формат
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

			-- хоткеи
			vim.keymap.set("n", "<leader>cf", function()
				conform.format({ async = false, lsp_format = "fallback" })
			end, { desc = "Conform: format buffer" })

			vim.keymap.set("v", "<leader>cF", function()
				conform.format({ async = false, lsp_format = "fallback" })
			end, { desc = "Conform: format selection" })

			-- тоггл автоформата (глобально)
			vim.keymap.set("n", "<leader>ct", function()
				local new = not (vim.g.disable_autoformat or false)
				vim.g.disable_autoformat = new
				vim.notify("Conform: autoformat " .. (new and "OFF" or "ON"))
			end, { desc = "Conform: toggle autoformat (global)" })

			-- команды
			vim.api.nvim_create_user_command("Format", function()
				conform.format({ async = false, lsp_format = "fallback" })
			end, {})

			vim.api.nvim_create_user_command("FormatDisable", function()
				vim.b.disable_autoformat = true
				vim.g.disable_autoformat = true
				vim.notify("Conform: autoformat disabled")
			end, {})

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
				vim.notify("Conform: autoformat enabled")
			end, {})
		end,
	},
}
