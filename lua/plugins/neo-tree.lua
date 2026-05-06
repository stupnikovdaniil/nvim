-- ~/.config/nvim/lua/theprimeagen/lazy/neo-tree.lua
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

        keys = {
            {
                "<leader>e",
                function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == "neo-tree" then
                            vim.api.nvim_set_current_win(win)
                            return
                        end
                    end

                    vim.cmd("Neotree reveal left")
                    vim.schedule(function()
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if vim.bo[buf].filetype == "neo-tree" then
                                vim.api.nvim_set_current_win(win)
                                return
                            end
                        end
                    end)
                end,
                desc = "Open/focus file tree",
                mode = "n",
            },
            {
                "<leader>E",
                function()
                    vim.cmd("Neotree close")
                end,
                desc = "Close file tree",
                mode = "n",
            },
        },

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
                    ["Z"]     = "expand_all_subnodes", -- ¿¿¿¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿¿¿¿¿ ¿¿ ¿¿¿¿¿ ¿¿¿¿¿¿
                    ["z"]     = "close_all_nodes",     -- ¿¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿
                },
            },
            event_handlers = {
                {
                    event = "neo_tree_buffer_enter",
                    handler = function(_)
                        local win = vim.api.nvim_get_current_win()
                        vim.wo[win].number = true
                        vim.wo[win].numberwidth = 3
                        vim.wo[win].cursorline = true
                        vim.wo[win].cursorlineopt = "number"
                        vim.wo[win].signcolumn = "yes"
                        vim.wo[win].foldcolumn = "0"
                    end,
                },
                {
                    event = "neo_tree_window_after_open",
                    handler = function(_)
                        local win = vim.api.nvim_get_current_win()
                        vim.wo[win].number = true
                        vim.wo[win].numberwidth = 3
                        vim.wo[win].cursorline = true
                        vim.wo[win].cursorlineopt = "number"
                        vim.wo[win].signcolumn = "yes"
                        vim.wo[win].foldcolumn = "0"
                    end,
                },
            },
        },

        config = function(_, opts)
            require("neo-tree").setup(opts)

            ----------------------------------------------------------------------
            -- Focus-aware numbering for neo-tree (relative only when focused)
            ----------------------------------------------------------------------
            local nt_focus_grp = vim.api.nvim_create_augroup("NeoTreeFocusNumbers", { clear = true })

            vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
                group = nt_focus_grp,
                callback = function(args)
                    local win = args.win or vim.api.nvim_get_current_win()
                    if not vim.api.nvim_win_is_valid(win) then return end
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype ~= "neo-tree" then return end
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(win) then
                            vim.wo[win].number = true
                            vim.wo[win].relativenumber = true
                            vim.wo[win].numberwidth = 3
                            vim.wo[win].cursorline = true
                            vim.wo[win].cursorlineopt = "number"
                            vim.wo[win].signcolumn = "yes"
                            vim.wo[win].foldcolumn = "0"
                        end
                    end)
                end,
            })

            vim.api.nvim_create_autocmd("WinLeave", {
                group = nt_focus_grp,
                callback = function(args)
                    local win = args.win or vim.api.nvim_get_current_win()
                    if not vim.api.nvim_win_is_valid(win) then return end
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype ~= "neo-tree" then return end
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(win) then
                            vim.wo[win].relativenumber = false
                            vim.wo[win].number = true
                        end
                    end)
                end,
            })

            ----------------------------------------------------------------------
            -- Autostart tree (show left, focus editor)
            ----------------------------------------------------------------------
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == "neo-tree" then
                            return
                        end
                    end
                    vim.cmd("Neotree show left")
                    vim.schedule(function()
                        pcall(vim.cmd, "Neotree reveal")
                        vim.cmd("wincmd p")
                    end)
                end,
            })

            ----------------------------------------------------------------------
            -- ;n / ;N inside tree (jump / open)
            ----------------------------------------------------------------------
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "neo-tree",
                callback = function()
                    local function goto_line_in_tree(open_file)
                        local input = vim.fn.input("Line #: ")
                        local lnum = tonumber(input)
                        if not lnum then return end

                        local max = vim.api.nvim_buf_line_count(0)
                        if lnum < 1 then lnum = 1 end
                        if lnum > max then lnum = max end

                        vim.api.nvim_win_set_cursor(0, { lnum, 0 })

                        if open_file then
                            local renderer = require("neo-tree.ui.renderer")
                            local node = renderer.get_node()
                            if node and node.type ~= "directory" and not node:has_children() then
                                local manager = require("neo-tree.sources.manager")
                                local fs = manager.get_state("filesystem")
                                require("neo-tree.sources.filesystem.commands").open(fs)
                            end
                        end
                    end

                    vim.keymap.set("n", ";n", function() goto_line_in_tree(false) end,
                        { buffer = true, desc = "Neo-tree: go to line" })
                    vim.keymap.set("n", ";N", function() goto_line_in_tree(true) end,
                        { buffer = true, desc = "Neo-tree: go to line and open" })
                end,
            })

            ----------------------------------------------------------------------
            -- Recursive expand helpers + mappings/commands
            ----------------------------------------------------------------------
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "neo-tree",
                callback = function()
                    local renderer = require("neo-tree.ui.renderer")
                    local manager  = require("neo-tree.sources.manager")

                    -- DFS: ¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿ ¿ ¿¿¿ ¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿
                    local function expand_node_recursive(state, node_id)
                        if not node_id then return end
                        local node = state.tree:get_node(node_id)
                        if not node then return end

                        local is_dir = (node.type == "directory") or node:has_children()
                        if not is_dir then return end

                        -- ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ ¿¿ ¿¿¿¿ ¿, ¿¿¿¿ ¿¿ ¿¿ ¿¿¿¿¿¿¿, ¿¿¿¿¿¿¿¿
                        renderer.focus_node(state, node_id)
                        if not node:is_expanded() then
                            state.commands.toggle_node(state)   -- ¿¿¿¿¿¿¿¿¿ ¿¿¿¿
                            node = state.tree:get_node(node_id) -- ¿¿¿¿¿¿¿ ¿¿¿¿¿¿
                        end

                        -- ¿¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿
                        local children = node:get_child_ids() or {}
                        for _, child_id in ipairs(children) do
                            local child = state.tree:get_node(child_id)
                            if child and ((child.type == "directory") or child:has_children()) then
                                expand_node_recursive(state, child_id)
                            end
                        end
                    end

                    -- ¿¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿¿¿ ¿¿ ¿¿¿¿¿¿¿ ¿¿¿¿¿¿ ¿ ¿¿¿¿¿¿
                    local function expand_all(state)
                        local roots = state.tree:get_nodes() or {}
                        for _, root_id in ipairs(roots) do
                            expand_node_recursive(state, root_id)
                        end
                    end

                    -- ¿¿¿¿¿¿¿¿ ¿¿¿ (¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿)
                    local function collapse_all(state)
                        state.commands.close_all_nodes(state)
                    end

                    -- ¿¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿¿¿
                    local function expand_current_dir_recursive()
                        local state = manager.get_state("filesystem")
                        local node  = state.tree:get_node() -- ¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿¿¿
                        if not node then return end
                        -- ¿¿¿¿ ¿¿¿¿¿¿ ¿¿ ¿¿¿¿¿ ¿ ¿¿¿¿¿ ¿¿¿¿¿¿¿¿
                        if not (node.type == "directory" or node:has_children()) then
                            local parent_id = node.get_parent_id and node:get_parent_id() or node.parent_id
                            if not parent_id then return end
                            node = state.tree:get_node(parent_id)
                        end
                        if not node then return end
                        expand_node_recursive(state, node:get_id())
                    end

                    -- ¿¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿ ¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿
                    local function expand_project_all()
                        local state = manager.get_state("filesystem")
                        expand_all(state)
                    end

                    -- ¿¿¿¿¿¿¿¿ ¿¿¿ ¿¿¿¿¿¿
                    local function collapse_project_all()
                        local state = manager.get_state("filesystem")
                        collapse_all(state)
                    end

                    -- ¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿ ¿¿¿¿ Neo-tree:
                    --  zr  ¿ ¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿
                    --  zR  ¿ ¿¿¿¿¿¿¿¿ ¿¿¿
                    --  zM  ¿ ¿¿¿¿¿¿¿¿ ¿¿¿
                    vim.keymap.set("n", "zr", expand_current_dir_recursive,
                        { buffer = true, desc = "Neo-tree: recursively expand current dir" })
                    vim.keymap.set("n", "zR", expand_project_all,
                        { buffer = true, desc = "Neo-tree: expand ALL" })
                    vim.keymap.set("n", "zM", collapse_project_all,
                        { buffer = true, desc = "Neo-tree: collapse ALL" })

                    -- ¿¿¿¿¿¿¿ (¿¿ ¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿)
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeExpandRecursive",
                        function() expand_current_dir_recursive() end, {})
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeExpandAll",
                        function() expand_project_all() end, {})
                    vim.api.nvim_buf_create_user_command(0, "NeoTreeCollapseAll",
                        function() collapse_project_all() end, {})
                end,
            })

            ----------------------------------------------------------------------
            -- Helpers
            ----------------------------------------------------------------------
            local function find_tree_win()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "neo-tree" then
                        return win
                    end
                end
                return nil
            end

            local function ensure_tree_and_get_win()
                local win = find_tree_win()
                if win then return win end
                vim.cmd("Neotree show left")
                vim.wait(500, function() return find_tree_win() ~= nil end, 10, false)
                return find_tree_win()
            end

            local function get_current_tree_node()
                local ok_r, renderer = pcall(require, "neo-tree.ui.renderer")
                if ok_r then
                    if type(renderer.get_node) == "function" then
                        local ok, node = pcall(renderer.get_node)
                        if ok and node then return node end
                    end
                    if type(renderer.get_node_at_cursor) == "function" then
                        local ok, node = pcall(renderer.get_node_at_cursor)
                        if ok and node then return node end
                    end
                end
                local ok_m, manager = pcall(require, "neo-tree.sources.manager")
                if ok_m then
                    local fs = manager.get_state("filesystem")
                    if fs and fs.tree and type(fs.tree.get_node) == "function" then
                        local lnum = vim.api.nvim_win_get_cursor(0)[1]
                        local ok1, node1 = pcall(fs.tree.get_node, fs.tree, lnum)
                        if ok1 and node1 then return node1 end
                    end
                end
                return nil
            end

            ----------------------------------------------------------------------
            -- Jump to tree line (from editor)
            ----------------------------------------------------------------------
            local function jump_in_tree_from_editor(open_file)
                local input = vim.fn.input("Neo-tree line #: ")
                local lnum = tonumber(input)
                if not lnum then return end

                local prev_editor = (function()
                    local cur = vim.api.nvim_get_current_win()
                    local function is_editor(win)
                        local buf = vim.api.nvim_win_get_buf(win)
                        return vim.bo[buf].filetype ~= "neo-tree"
                    end
                    if vim.api.nvim_win_is_valid(cur) and is_editor(cur) then return cur end
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if is_editor(win) then return win end
                    end
                    return nil
                end)()

                local tree_win = ensure_tree_and_get_win()
                if not tree_win then
                    vim.notify("Neo-tree window not found", vim.log.levels.WARN)
                    return
                end

                vim.api.nvim_set_current_win(tree_win)
                local max = vim.api.nvim_buf_line_count(0)
                if max == 0 then return end
                if lnum < 1 then lnum = 1 end
                if lnum > max then lnum = max end
                vim.api.nvim_win_set_cursor(tree_win, { lnum, 0 })

                if not open_file then return end

                local node = get_current_tree_node()
                if not node then return end

                local is_dir = (node.type == "directory")
                    or (type(node.has_children) == "function" and node:has_children())
                    or (node.children ~= nil)
                if is_dir then return end

                local path = (type(node.get_id) == "function" and node:get_id()) or node.path
                if not path or path == "" then return end

                local target = prev_editor
                if not (target and vim.api.nvim_win_is_valid(target)) then
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype ~= "neo-tree" then
                            target = win
                            break
                        end
                    end
                end

                if target and vim.api.nvim_win_is_valid(target) then
                    vim.api.nvim_win_call(target, function()
                        vim.cmd("keepalt keepjumps edit " .. vim.fn.fnameescape(path))
                    end)
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(target) then
                            pcall(vim.api.nvim_set_current_win, target)
                        end
                    end)
                else
                    local ok_m, manager = pcall(require, "neo-tree.sources.manager")
                    if ok_m then
                        local fs = manager.get_state("filesystem")
                        require("neo-tree.sources.filesystem.commands").open(fs)
                        vim.schedule(function()
                            local cur = vim.api.nvim_get_current_win()
                            local buf = vim.api.nvim_win_get_buf(cur)
                            if vim.bo[buf].filetype == "neo-tree" then
                                vim.cmd("vsplit " .. vim.fn.fnameescape(path))
                            end
                        end)
                    end
                end
            end

            ----------------------------------------------------------------------
            -- Editor mappings
            ----------------------------------------------------------------------
            vim.keymap.set("n", "<leader>tf", function() jump_in_tree_from_editor(true) end,
                { desc = "Neo-tree: open by line, focus file" })

            vim.keymap.set("n", "<leader>tt", function() jump_in_tree_from_editor(false) end,
                { desc = "Neo-tree: move to line in tree, keep focus" })
        end,
    },
}
