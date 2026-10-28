local function large_buffer(bufnr)
    return vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > 512 * 1024
end

return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "ConformInfo", "Format", "FormatDisable", "FormatEnable", "FormatStatus" },
        keys = require("config.keys").plugin("conform"),

        opts = {
            -- Small buffers format before saving; large buffers format after saving.
            format_on_save = function(bufnr)
                if require("config.formatting").disabled(bufnr) or large_buffer(bufnr) then return end
                return { lsp_format = "fallback", timeout_ms = 5000 }
            end,
            format_after_save = function(bufnr)
                if require("config.formatting").disabled(bufnr) or not large_buffer(bufnr) then return end
                return { lsp_format = "fallback", timeout_ms = 8000 }
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
                json = { "prettierd", "prettier", stop_after_first = true },
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

            require("config.formatting").setup()
            vim.api.nvim_create_user_command("Format", function()
                conform.format({ lsp_format = "fallback" })
            end, { desc = "Format current buffer" })
        end,
    },
}
