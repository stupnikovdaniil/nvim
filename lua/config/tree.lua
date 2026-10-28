local M = {}

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

----------------------------------------------------------------------
-- Hint navigation from the editor. Keep existing shortcut meanings.
----------------------------------------------------------------------
function M.hint(open_file)
    local tree_win = ensure_tree_and_get_win()
    if not tree_win then
        vim.notify("Neo-tree window not found", vim.log.levels.WARN)
        return
    end
    vim.api.nvim_set_current_win(tree_win)
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    local ready = vim.wait(2000, function()
        return vim.api.nvim_win_is_valid(tree_win)
            and state.tree ~= nil
            and #state.tree:get_nodes() > 0
    end, 10)
    if not ready then
        vim.notify("Neo-tree is not ready for hints", vim.log.levels.WARN)
        return
    end
    vim.api.nvim_set_current_win(tree_win)
    require("neo_tree_hints").jump(state, open_file)
end

function M.open()
    local win = find_tree_win()
    if win then
        vim.api.nvim_set_current_win(win)
        return
    end
    vim.cmd("Neotree reveal left")
end

function M.expand_current()
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    local node = state.tree:get_node()
    if not node then return end
    if node.type ~= "directory" then node = state.tree:get_node(node:get_parent_id()) end
    if node then state.commands.expand_all_subnodes(state, node) end
end

function M.expand_all()
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    state.commands.expand_all_nodes(state)
end

function M.collapse_all()
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    state.commands.close_all_nodes(state)
end

return M
