local function setup_tree_window()
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].numberwidth = 3
    vim.wo[win].cursorline = true
    vim.wo[win].cursorlineopt = "number"
    vim.wo[win].signcolumn = "yes"
    vim.wo[win].foldcolumn = "0"
end

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        keys = require("config.keys").plugin("tree"),

        opts = {
            close_if_last_window = true,
            filesystem = {
                hijack_netrw_behavior = "open_default",
                follow_current_file   = { enabled = false },
                filtered_items        = { visible = true, hide_dotfiles = false },
            },
            window = {
                width = 32,
                mappings = {
                    ["h"]     = "close_node",
                    ["l"]     = "open",
                    ["o"]     = "toggle_node",
                    ["n"]     = { "add", config = { show_path = "relative" } },
                    ["e"]     = "open",
                    ["r"]     = "rename",
                    ["dd"]    = "delete",
                    ["yy"]    = "copy_to_clipboard",
                    ["p"]     = "paste_from_clipboard",
                    ["m"]     = "move",
                    ["<BS>"]  = "navigate_up",
                    ["<esc>"] = function() vim.cmd("wincmd p") end,
                    ["<C-c>"] = function() vim.cmd("wincmd p") end,
                    ["q"]     = "close_window",
                    ["Z"]     = "expand_all_subnodes",
                    ["z"]     = "close_all_nodes",
                },
            },
            event_handlers = {
                {
                    event = "neo_tree_buffer_enter",
                    handler = function(_)
                        setup_tree_window()
                    end,
                },
                {
                    event = "neo_tree_window_after_open",
                    handler = function(_)
                        setup_tree_window()
                    end,
                },
            },
        },

        config = function(_, opts)
            require("neo-tree").setup(opts)

            ----------------------------------------------------------------------
            -- Relative numbers only while Neo-tree is focused.
            ----------------------------------------------------------------------
            local nt_focus_grp = vim.api.nvim_create_augroup("NeoTreeFocusNumbers", { clear = true })

            vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
                group = nt_focus_grp,
                callback = function()
                    local win = vim.api.nvim_get_current_win()
                    if not vim.api.nvim_win_is_valid(win) then return end
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype ~= "neo-tree" then return end
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(win)
                            and vim.api.nvim_get_current_win() == win then
                            vim.wo[win].number = true
                            vim.wo[win].relativenumber = true
                            vim.wo[win].numberwidth = 3
                            vim.wo[win].cursorline = true
                            vim.wo[win].cursorlineopt = "number"
                        end
                    end)
                end,
            })

            vim.api.nvim_create_autocmd("WinLeave", {
                group = nt_focus_grp,
                callback = function()
                    local win = vim.api.nvim_get_current_win()
                    if not vim.api.nvim_win_is_valid(win) then return end
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype ~= "neo-tree" then return end
                    vim.wo[win].relativenumber = false
                    vim.wo[win].number = false
                end,
            })

            ----------------------------------------------------------------------
            -- Recursive expand helpers + mappings/commands
            ----------------------------------------------------------------------
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "neo-tree",
                callback = function()
                    require("config.keys").apply("tree_buffer", { buffer = true })
                    local tree = require("config.tree")
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeExpandRecursive", tree.expand_current, {})
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeExpandAll", tree.expand_all, {})
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeCollapseAll", tree.collapse_all, {})
                end,
            })

        end,
    },
}
