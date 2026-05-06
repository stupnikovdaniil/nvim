-- ~/.config/nvim/lua/plugins/lsp.lua

local root_files = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local lsp_group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = lsp_group,
            callback = function(e)
                local opts = function(desc)
                    return { buffer = e.buf, silent = true, desc = desc }
                end

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("LSP: definition"))
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("LSP: declaration"))
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("LSP: implementation"))
                vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts("LSP: type definition"))
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("LSP: references"))

                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("LSP: hover"))
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("LSP: rename"))
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("LSP: code action"))

                vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, opts("Diagnostic: line details"))
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("Diagnostic: next"))
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("Diagnostic: previous"))

                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("LSP: signature help"))
            end,
        })
        ------------------------------------------------------------
        -- FORMATTERS (conform.nvim)
        ------------------------------------------------------------
        require("conform").setup({
            format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
            formatters_by_ft = {
                lua        = { "stylua" },
                python     = { "black", "isort" },
                go         = { "gofumpt", "goimports" },
                rust       = { "rustfmt" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json       = { "prettier" },
                yaml       = { "prettier" },
                markdown   = { "mdformat" },
                terraform  = { "terraform_fmt" },
                hcl        = { "terraform_fmt" },
                sh         = { "shfmt" },
                bash       = { "shfmt" },
                toml       = { "taplo" },
                sql        = { "sqlfluff" },
            },
            formatters = {
                sqlfluff = { prepend_args = { "--dialect", "postgres" } },
            },
        })

        ------------------------------------------------------------
        -- CMP + CAPABILITIES
        ------------------------------------------------------------
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        ------------------------------------------------------------
        -- BASE SERVICES
        ------------------------------------------------------------
        require("fidget").setup({})
        require("mason").setup()

        -- tsserver → ts_ls (совместимость)
        local has_ts_ls = pcall(function()
            return require("lspconfig.configs").ts_ls
        end)
        local TS_NAME = has_ts_ls and "ts_ls" or "tsserver"

        require("mason-lspconfig").setup({
            ensure_installed = {
                -- vim-семейство
                "vimls",

                -- основные языки
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "pyright",
                "bashls",

                -- фронт-энд
                TS_NAME,
                "eslint",
                "jsonls",
                "yamlls",

                -- конфигурационные форматы
                "taplo",
                "dockerls",
                "terraformls",

                -- разметка и документация
                "marksman",

                -- SQL и шаблоны
                "sqls",
                "templ",

                -- DevOps
                "ansiblels",
            },

            handlers = {
                --------------------------------------------------------
                -- Default handler for any installed server
                --------------------------------------------------------
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                --------------------------------------------------------
                -- CUSTOM CONFIGS
                --------------------------------------------------------

                ["lua_ls"] = function()
                    local util = require("lspconfig.util")
                    require("lspconfig").lua_ls.setup({
                        capabilities = capabilities,
                        root_dir = util.root_pattern(unpack(root_files)),
                        settings = {
                            Lua = {
                                diagnostics = { globals = { "vim" } },
                                format = {
                                    enable = true,
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    },
                                },
                            },
                        },
                    })
                end,

                [TS_NAME] = function()
                    local util = require("lspconfig.util")
                    require("lspconfig")[TS_NAME].setup({
                        capabilities = capabilities,
                        root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
                    })
                end,

                ["yamlls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.yamlls.setup({
                        capabilities = capabilities,
                        settings = {
                            yaml = {
                                schemaStore = {
                                    enable = true,
                                    url =
                                    "https://www.schemastore.org/api/json/catalog.json",
                                },
                                schemas = {
                                    ["https://json.schemastore.org/github-workflow.json"] =
                                    ".github/workflows/*.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] =
                                    "docker-compose*.{yml,yaml}",
                                    ["https://json.schemastore.org/ansible-playbook.json"] = {
                                        "playbooks/**/*.{yml,yaml}",
                                        "ansible/**/*.{yml,yaml}",
                                    },
                                },
                                format = { enable = true },
                                validate = true,
                            },
                        },
                    })
                end,

                ["jsonls"] = function()
                    require("lspconfig").jsonls.setup({
                        capabilities = capabilities,
                        settings = {
                            json = {
                                validate = { enable = true },
                                schemaDownload = { enable = true },
                            },
                        },
                    })
                end,

                ["ansiblels"] = function()
                    require("lspconfig").ansiblels.setup({
                        capabilities = capabilities,
                        filetypes = { "yaml", "yaml.ansible", "ansible" },
                    })
                end,

                ["terraformls"] = function()
                    require("lspconfig").terraformls.setup({
                        capabilities = capabilities,
                    })
                end,

                ["sqls"] = function()
                    require("lspconfig").sqls.setup({
                        capabilities = capabilities,
                        settings = {
                            sqls = {
                                connections = {
                                    -- пример:
                                    -- { driver = "postgresql",
                                    --   dataSourceName = "host=127.0.0.1 port=5432 user=gpadmin dbname=postgres sslmode=disable" },
                                },
                            },
                        },
                    })
                end,
            },
        })

        ------------------------------------------------------------
        -- CMP CONFIG
        ------------------------------------------------------------
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                ["<C-l>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
            experimental = { ghost_text = true },
        })

        ------------------------------------------------------------
        -- DIAGNOSTICS
        ------------------------------------------------------------
        vim.diagnostic.config({
            virtual_text = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}
