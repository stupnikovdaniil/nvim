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
                require("config.keys").apply("lsp", { buffer = e.buf })
            end,
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

        -- Configure servers before Mason enables them (Neovim 0.11+).
        vim.lsp.config("*", { capabilities = capabilities })
        vim.lsp.config("lua_ls", {
            root_markers = root_files,
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    format = {
                        enable = true,
                        defaultConfig = { indent_style = "space", indent_size = "4" },
                    },
                },
            },
        })
        vim.lsp.config("ts_ls", {
            root_markers = { "tsconfig.json", "package.json", ".git" },
        })
        vim.lsp.config("yamlls", {
            settings = {
                yaml = {
                    schemaStore = {
                        enable = true,
                        url = "https://www.schemastore.org/api/json/catalog.json",
                    },
                    schemas = {
                        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
                        ["https://json.schemastore.org/ansible-playbook.json"] = {
                            "playbooks/**/*.{yml,yaml}", "ansible/**/*.{yml,yaml}",
                        },
                    },
                    format = { enable = true },
                    validate = true,
                },
            },
        })
        vim.lsp.config("jsonls", {
            settings = { json = { validate = { enable = true }, schemaDownload = { enable = true } } },
        })
        vim.lsp.config("ansiblels", { filetypes = { "yaml", "yaml.ansible", "ansible" } })
        vim.lsp.config("sqls", { settings = { sqls = { connections = {} } } })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "vimls", "lua_ls", "rust_analyzer", "gopls", "pyright", "bashls",
                "ts_ls", "eslint", "jsonls", "yamlls", "taplo", "dockerls",
                "terraformls", "marksman", "sqls", "templ", "ansiblels",
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
