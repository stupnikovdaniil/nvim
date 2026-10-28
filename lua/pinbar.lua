--lua/pinbar.lua
local M = {}

-- internal helpers ------------------------------------------------------------
local function valid_buf(b)
    return b and type(b) == "number" and vim.api.nvim_buf_is_valid(b)
end

local function is_tree(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype == "neo-tree"
end

local function get(win)
    local ok, list = pcall(vim.api.nvim_win_get_var, win, "pinbar")
    if not ok or type(list) ~= "table" then list = {} end
    local out, seen = {}, {}
    for _, b in ipairs(list) do
        if valid_buf(b) and not seen[b] then
            table.insert(out, b)
            seen[b] = true
        end
    end
    return out
end

local function set(win, list)
    vim.api.nvim_win_set_var(win, "pinbar", list)
end

local function to_parts(full)
    if full == "" then return { "[No Name]" } end
    local p = vim.fn.fnamemodify(full, ":p")
    return vim.split(p, "/", { plain = true, trimempty = true })
end

local function shortest_unique_suffix(items)
    local by_base, labels = {}, {}
    for _, it in ipairs(items) do
        local base = it.parts[#it.parts] or it.path
        by_base[base] = by_base[base] or {}
        table.insert(by_base[base], it)
    end
    for _, group in pairs(by_base) do
        if #group == 1 then
            local it = group[1]
            labels[it.path] = (it.parts[#it.parts] or it.path)
        else
            local depth, unique = 1, false
            while not unique do
                local seen = {}
                unique = true
                for _, it in ipairs(group) do
                    local p, start = {}, math.max(1, #it.parts - depth)
                    for i = start, #it.parts do table.insert(p, it.parts[i]) end
                    local label = table.concat(p, "/")
                    if seen[label] then unique = false end
                    seen[label] = true
                end
                if not unique then depth = depth + 1 end
                if depth > (#group[1].parts) then break end
            end
            for _, it in ipairs(group) do
                local p, start = {}, math.max(1, #it.parts - depth)
                for i = start, #it.parts do table.insert(p, it.parts[i]) end
                labels[it.path] = table.concat(p, "/")
            end
        end
    end
    return labels
end

local function refresh_winbar(win)
    if is_tree(win) then
        vim.api.nvim_win_call(win, function() vim.opt_local.winbar = "" end)
        return
    end

    local list = get(win)
    if #list == 0 then
        vim.api.nvim_win_call(win, function() vim.opt_local.winbar = "" end)
        return
    end

    local infos = {}
    for _, b in ipairs(list) do
        local full = vim.api.nvim_buf_get_name(b)
        table.insert(infos, {
            buf = b,
            path = (full ~= "" and full) or "[No Name]",
            parts = to_parts(full),
        })
    end

    local labels = shortest_unique_suffix(infos)
    local cur = vim.api.nvim_win_get_buf(win)
    local segs = {}

    for i, b in ipairs(list) do
        local full = vim.api.nvim_buf_get_name(b)
        local key = (full ~= "" and full) or "[No Name]"
        local lbl
        if labels[key] then
            lbl = labels[key]
        else
            -- Always show parent/file for clarity
            local parent = vim.fn.fnamemodify(full, ":h:t")
            local base = vim.fn.fnamemodify(full, ":t")
            lbl = (parent ~= "" and (parent .. "/" .. base)) or base
        end
        if vim.bo[b].modified then lbl = lbl .. "*" end
        local text = string.format("[%d %s]", i, (lbl:gsub("%%", "%%%%")))
        if b == cur then
            table.insert(segs, "%#Title#" .. text .. "%*")
        else
            table.insert(segs, text)
        end
    end

    vim.api.nvim_win_call(win, function()
        vim.opt_local.winbar = table.concat(segs, " ")
    end)
end

local function refresh_all()
    for _, w in ipairs(vim.api.nvim_list_wins()) do refresh_winbar(w) end
end

-- public ---------------------------------------------------------------------
function M.setup()
    local aug = vim.api.nvim_create_augroup("pinbar.core", { clear = true })

    vim.api.nvim_create_autocmd(
        { "WinEnter", "BufWinEnter", "BufFilePost", "BufModifiedSet" },
        { group = aug, callback = refresh_all }
    )

    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = aug,
        callback = function(a)
            local dead = a.buf
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                local list, out, changed = get(w), {}, false
                for _, b in ipairs(list) do
                    if b ~= dead then table.insert(out, b) else changed = true end
                end
                if changed then set(w, out) end
            end
            refresh_all()
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = aug,
        callback = function(ev)
            local win = tonumber(ev.match) or 0
            pcall(vim.api.nvim_win_del_var, win, "pinbar")
        end,
    })
end

function M.pin_current()
    local win = vim.api.nvim_get_current_win()
    if is_tree(win) then return end
    local buf = vim.api.nvim_get_current_buf()
    if not valid_buf(buf) then return end
    local list, seen = get(win), {}
    for _, b in ipairs(list) do seen[b] = true end
    if not seen[buf] then
        table.insert(list, buf); set(win, list)
    end
    refresh_winbar(win)
end

function M.goto_index(i)
    local win = vim.api.nvim_get_current_win()
    local list = get(win)
    if i < 1 or i > #list then return end
    local buf = list[i]
    if not valid_buf(buf) then return end
    vim.api.nvim_set_current_buf(buf)
    refresh_winbar(win)
end

function M.remove_index(i)
    local win = vim.api.nvim_get_current_win()
    local list = get(win)
    if i < 1 or i > #list then return end
    table.remove(list, i)
    set(win, list)
    refresh_winbar(win)
end

return M
