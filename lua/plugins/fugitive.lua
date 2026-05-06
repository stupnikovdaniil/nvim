-- ~/.config/nvim/lua/plugins/fugitive.lua
return {
    {
        "tpope/vim-fugitive",
        dependencies = { "tpope/vim-rhubarb" }, -- чтобы :GBrowse открывал ссылку в GitHub/и др.
        cmd = {
            "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit",
            "Gread", "Gwrite", "GMove", "GRename", "GDelete", "GRemove",
            "Ggrep", "Glgrep", "GBrowse", "Gblame",
        },
        init = function()
            local map = vim.keymap.set
            local opt = { silent = true, noremap = true }

            -- Основное
            map("n", "<leader>gs", ":Git<CR>",
                vim.tbl_extend("force", opt, { desc = "Git status (Fugitive)" }))
            map("n", "<leader>gd", ":Gdiffsplit<CR>",
                vim.tbl_extend("force", opt, { desc = "Git diff split" }))
            map("n", "<leader>gc", ":Git commit<CR>", vim.tbl_extend("force", opt, { desc = "Git commit" }))
            map("n", "<leader>gp", ":Git push<CR>", vim.tbl_extend("force", opt, { desc = "Git push" }))
            map("n", "<leader>gP", ":Git pull<CR>", vim.tbl_extend("force", opt, { desc = "Git pull" }))

            -- Текущий файл
            map("n", "<leader>gb", ":Gblame<CR>",
                vim.tbl_extend("force", opt, { desc = "Git blame (buffer)" }))
            map("n", "<leader>gB", ":GBrowse<CR>",
                vim.tbl_extend("force", opt, { desc = "Open in remote (GBrowse)" }))
            map("v", "<leader>gB", ":GBrowse<CR>",
                vim.tbl_extend("force", opt, { desc = "Open selection in remote" }))

            map("n", "<leader>gr", ":Gread<CR>",
                vim.tbl_extend("force", opt, { desc = "Checkout file (discard changes)" }))
            map("n", "<leader>gw", ":Gwrite<CR>",
                vim.tbl_extend("force", opt, { desc = "Stage file (:Gwrite)" }))
            map("n", "<leader>gM", ":GMove ", vim.tbl_extend("force", opt, { desc = "git mv (prompt path)" }))
            map("n", "<leader>gD", ":GDelete<CR>",
                vim.tbl_extend("force", opt, { desc = "git rm + close buffer" }))

            -- История/поиск
            map("n", "<leader>gl", ":Git log -p -- %<CR>",
                vim.tbl_extend("force", opt, { desc = "Git log current file" }))
            map("n", "<leader>gg", ":Ggrep ", vim.tbl_extend("force", opt, { desc = "git grep -> quickfix" }))
        end,
    },
}
