local M = {}
local alphabet, prefix
local slots, buffers = {}, {}

local function label_for_slot(slot)
    local label = ""
    while slot > #alphabet do
        label = label .. prefix
        slot = slot - #alphabet
    end
    return label .. alphabet:sub(slot, slot)
end

local function release(bufnr)
    local slot = slots[bufnr]
    if slot then buffers[slot], slots[bufnr] = nil, nil end
end

-- Labels belong to buffer IDs, so sorting or closing other buffers cannot move them.
function M.label(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then return "" end
    if not slots[bufnr] then
        local slot = 1
        while buffers[slot] do slot = slot + 1 end
        slots[bufnr], buffers[slot] = slot, bufnr
    end
    return label_for_slot(slots[bufnr])
end

local function jump(slot)
    local bufnr = buffers[slot]
    if not bufnr then return end
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
        release(bufnr)
        return
    end
    -- Use the public Neovim API rather than bufferline's internal component list.
    if vim.bo.filetype == "neo-tree" then
        vim.cmd("wincmd p")
        if vim.bo.filetype == "neo-tree" then vim.cmd("rightbelow vnew") end
    end
    vim.api.nvim_set_current_buf(bufnr)
end

function M.setup()
    alphabet, prefix = require("config.keys").label_alphabet()
    slots, buffers = {}, {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do M.label(bufnr) end
    local group = vim.api.nvim_create_augroup("BufferLabels", { clear = true })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = group,
        callback = function(event) release(event.buf) end,
    })
    for slot = 1, #alphabet do
        local letter = alphabet:sub(slot, slot)
        vim.keymap.set("n", "<leader>" .. letter, function() jump(slot) end, {
            silent = true, desc = "Buffer: " .. letter,
        })
    end
    vim.keymap.set("n", "<leader>" .. prefix, function()
        local offset = #alphabet
        while true do
            local ok, key = pcall(vim.fn.getcharstr)
            if not ok then return end
            if key == prefix then
                offset = offset + #alphabet
            else
                local slot = #key == 1 and alphabet:find(key, 1, true)
                if slot then jump(offset + slot) end
                return
            end
        end
    end, { silent = true, desc = "Buffer: extended letter label" })
end

return M
