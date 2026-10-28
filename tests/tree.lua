local runtime = dofile("tests/bootstrap.lua")
local plugin = require("lazy.core.config").plugins["neo-tree.nvim"]
assert(not plugin._.loaded, "Tree loaded before use")
assert(vim.fn.maparg(" tf", "n") ~= "" and vim.fn.maparg(" tt", "n") ~= "")
local fixture = vim.fn.stdpath("cache") .. "/tree-fixture"
vim.fn.mkdir(fixture .. "/folder", "p")
fixture = assert(vim.uv.fs_realpath(fixture))
vim.fn.writefile({ "local value = 1" }, fixture .. "/alpha.lua")
vim.fn.writefile({ "local value = 2" }, fixture .. "/beta.lua")
vim.api.nvim_set_current_dir(fixture)

local hints = require("neo_tree_hints")
local original_jump = hints.jump
local called = false
hints.jump = function(state, open)
    assert(state.tree, "Tree not ready")
    assert(vim.bo.filetype == "neo-tree", "Wrong window")
    assert(open == (vim.env.NVIM_HINT_KEY == "tf"))
    local renderer = require("neo-tree.ui.renderer")
    local top, bottom = vim.fn.line("w0"), vim.fn.line("w$")
    local rows = {}
    for _, node in ipairs(renderer.get_all_visible_nodes(state.tree)) do
        local _, line = state.tree:get_node(node:get_id())
        if line and line >= top and line <= bottom then
            rows[#rows + 1] = { id = node:get_id(), line = line }
        end
    end
    table.sort(rows, function(a, b) return a.line < b.line end)
    local alphabet = "kjwdfasleirutmnhgopqzxcvby"
    local width, capacity = 1, #alphabet
    while capacity < #rows do width, capacity = width + 1, capacity * #alphabet end
    local index
    for i, row in ipairs(rows) do
        if row.id == fixture .. "/alpha.lua" then index = i - 1 end
    end
    assert(index, "Fixture file is not visible: " .. vim.inspect({ rows = rows, top = top, bottom = bottom, path = state.path }))
    local label = ""
    for _ = 1, width do
        local digit = index % #alphabet + 1
        label = alphabet:sub(digit, digit) .. label
        index = math.floor(index / #alphabet)
    end
    local getchar = vim.fn.getcharstr
    local offset = 0
    vim.fn.getcharstr = function()
        offset = offset + 1
        return label:sub(offset, offset)
    end
    local ok, err = pcall(original_jump, state, open)
    vim.fn.getcharstr = getchar
    assert(ok, err)
    if open then
        assert(vim.api.nvim_buf_get_name(0) == fixture .. "/alpha.lua", "Hint did not open file")
    else
        assert(vim.bo.filetype == "neo-tree", "Focus hint opened file")
        assert(state.tree:get_node():get_id() == fixture .. "/alpha.lua", "Hint focused wrong node")
    end
    local ns = vim.api.nvim_get_namespaces().NeoTreeFileHints
    assert(#vim.api.nvim_buf_get_extmarks(state.bufnr, ns, 0, -1, {}) == 0, "Hint overlays leaked")
    called = true
end

local function trigger()
    called = false
    vim.api.nvim_feedkeys(" " .. vim.env.NVIM_HINT_KEY, "xt", false)
    assert(vim.wait(1500, function() return called end, 10), "Hint callback did not run")
end
trigger()
assert(plugin._.loaded, "Tree was not loaded by mapping")
vim.cmd("Neotree close")
trigger()
assert(#runtime.errors == 0, table.concat(runtime.errors, "\n"))
io.stdout:write("PASS First-use hints and reopen: " .. vim.env.NVIM_HINT_KEY .. "\n")
vim.cmd("qa!")
