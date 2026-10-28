local M = {}

-- All user mappings live here. Plugin-native menus keep their own local keys.
local function call(module, method, ...)
    local args = { ... }
    return function() return require(module)[method](unpack(args)) end
end

local function lsp(method)
    return function() vim.lsp.buf[method]() end
end

local function telescope(method, word)
    return function()
        local opts = word and { search = vim.fn.expand(word) } or nil
        require("telescope.builtin")[method](opts)
    end
end

local function project_files()
    local builtin = require("telescope.builtin")
    if not pcall(builtin.git_files, { show_untracked = true }) then builtin.find_files() end
end

M.bindings = {
    core = {
        { "<leader>n", function()
            vim.opt.number = not vim.opt.number:get()
            vim.opt.relativenumber = vim.opt.number:get()
        end, desc = "Toggle line numbers" },
        { "<C-h>", "<C-w>h", desc = "Window left" },
        { "<C-j>", "<C-w>j", desc = "Window down" },
        { "<C-l>", "<C-w>l", desc = "Window right" },
        { "<C-u>", "<C-w>k", desc = "Window up" },
        { "<leader>ws", "<C-w>s", desc = "Split horizontally" },
        { "<leader>wv", "<C-w>v", desc = "Split vertically" },
        { "<leader>wc", "<C-w>c", desc = "Close window" },
        { "<leader>w=", "<C-w>=", desc = "Equalize windows" },
        { "<", "<cmd>vertical resize -5<CR>", desc = "Shrink width" },
        { ">", "<cmd>vertical resize +5<CR>", desc = "Expand width" },
        { "<leader>pv", "<cmd>Explore<CR>", desc = "Open netrw explorer" },
        { "<leader>pp", call("pinbar", "pin_current"), desc = "Pin current file" },
    },
    bufferline = {
        { "<leader>h", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
        { "<leader>l", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
        { "<leader><leader>w", "<cmd>Bdelete<CR>", desc = "Delete current buffer" },
        { "<leader><leader>W", "<cmd>Bdelete!<CR>", desc = "Force delete current buffer" },
    },
    tree = {
        { "<leader>e", call("config.tree", "open"), desc = "Open/focus file tree" },
        { "<leader>E", "<cmd>Neotree close<CR>", desc = "Close file tree" },
        { "<leader>tf", call("config.tree", "hint", true), desc = "Neo-tree: open by hint" },
        { "<leader>tt", call("config.tree", "hint", false), desc = "Neo-tree: focus by hint" },
    },
    tree_buffer = {
        { "zr", call("config.tree", "expand_current"), desc = "Recursively expand current dir" },
        { "zR", call("config.tree", "expand_all"), desc = "Expand all directories" },
        { "zM", call("config.tree", "collapse_all"), desc = "Collapse all directories" },
    },
    conform = {
        { "<leader>cf", call("conform", "format", { lsp_format = "fallback" }), desc = "Format buffer" },
        { "<leader>cF", call("conform", "format", { lsp_format = "fallback" }), mode = "v", desc = "Format selection" },
        { "<leader>ct", call("config.formatting", "toggle", "global"), desc = "Toggle autoformat globally" },
        { "<leader>cT", call("config.formatting", "toggle", "buffer"), desc = "Toggle autoformat for buffer" },
    },
    telescope = {
        { "<C-p>", project_files, desc = "Find project file" },
        { "<leader>ff", telescope("find_files"), desc = "Find files" },
        { "<leader>fg", telescope("live_grep"), desc = "Live grep" },
        { "<leader>fw", telescope("grep_string", "<cword>"), desc = "Grep word" },
        { "<leader>fW", telescope("grep_string", "<cWORD>"), desc = "Grep WORD" },
        { "<leader>fb", telescope("buffers"), desc = "Find buffer" },
        { "<leader>fo", telescope("oldfiles"), desc = "Recent files" },
        { "<leader>fr", telescope("resume"), desc = "Resume search" },
        { "<leader>fh", telescope("help_tags"), desc = "Find help" },
    },
    fugitive = {
        { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
        { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git diff" },
        { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git commit" },
        { "<leader>gp", "<cmd>Git push<CR>", desc = "Git push" },
        { "<leader>gP", "<cmd>Git pull<CR>", desc = "Git pull" },
        { "<leader>gb", "<cmd>Gblame<CR>", desc = "Git blame" },
        { "<leader>gB", ":GBrowse<CR>", mode = { "n", "v" }, desc = "Browse in remote" },
        { "<leader>gr", "<cmd>Gread<CR>", desc = "Discard file changes" },
        { "<leader>gw", "<cmd>Gwrite<CR>", desc = "Stage file" },
        { "<leader>gM", ":GMove ", desc = "Move file" },
        { "<leader>gD", "<cmd>GDelete<CR>", desc = "Delete tracked file" },
        { "<leader>gl", ":Git log -p -- %<CR>", desc = "Git file history" },
        { "<leader>gg", ":Ggrep ", desc = "Git grep" },
    },
    trouble = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<CR>", desc = "Workspace diagnostics" },
        { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<CR>", desc = "Buffer diagnostics" },
        { "<leader>xs", "<cmd>Trouble symbols toggle focus=true<CR>", desc = "Document symbols" },
        { "gr", "<cmd>Trouble lsp_references toggle focus=true<CR>", desc = "LSP references" },
    },
    undotree = {
        { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
    },
    themes = {
        { "<leader>sr", "<cmd>ColorUse rose-pine-moon<CR>", desc = "Theme: Rose Pine" },
        { "<leader>st", "<cmd>ColorUse tokyonight<CR>", desc = "Theme: Tokyo Night" },
        { "<leader>sg", "<cmd>ColorUse gruvbox<CR>", desc = "Theme: Gruvbox" },
    },
    lsp = {
        { "gd", lsp("definition"), desc = "LSP definition" },
        { "gD", lsp("declaration"), desc = "LSP declaration" },
        { "gi", lsp("implementation"), desc = "LSP implementation" },
        { "gy", lsp("type_definition"), desc = "LSP type definition" },
        { "K", lsp("hover"), desc = "LSP hover" },
        { "<leader>rn", lsp("rename"), desc = "LSP rename" },
        { "<leader>ca", lsp("code_action"), desc = "LSP code action" },
        { "<leader>df", function() vim.diagnostic.open_float() end, desc = "Line diagnostics" },
        { "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, desc = "Next diagnostic" },
        { "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = "Previous diagnostic" },
        { "<C-h>", lsp("signature_help"), mode = "i", desc = "LSP signature help" },
    },
}

for i = 1, 9 do
    table.insert(M.bindings.core, { "<leader>" .. i, call("pinbar", "goto_index", i), desc = "Go to pin " .. i })
    table.insert(M.bindings.core, { "<leader>d" .. i, call("pinbar", "remove_index", i), desc = "Remove pin " .. i })
end

M.groups = {
    { "<leader>c", group = "code/format" },
    { "<leader>d", group = "diagnostics/remove pin" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>p", group = "pins" },
    { "<leader>r", group = "rename" },
    { "<leader>s", group = "theme" },
    { "<leader>t", group = "tree" },
    { "<leader>w", group = "windows" },
    { "<leader>x", group = "diagnostics" },
    { "g", group = "goto/LSP" },
    { "z", group = "fold/tree" },
    { "[", group = "previous" },
    { "]", group = "next" },
}

function M.plugin(name)
    return vim.deepcopy(assert(M.bindings[name], "Unknown key group: " .. name))
end

function M.apply(name, opts)
    for _, key in ipairs(M.bindings[name]) do
        vim.keymap.set(key.mode or "n", key[1], key[2], vim.tbl_extend("force", {
            silent = true, desc = key.desc,
        }, opts or {}))
    end
end

local function modes(key)
    return type(key.mode) == "table" and key.mode or { key.mode or "n" }
end

-- Buffer-local mappings are checked against globals too: shadowing is intentional
-- only when modes differ, as with normal/insert Ctrl-h.
function M.validate()
    local seen = {}
    for group, keys in pairs(M.bindings) do
        for _, key in ipairs(keys) do
            for _, mode in ipairs(modes(key)) do
                local lhs = vim.api.nvim_replace_termcodes(key[1]:gsub("<leader>", " "), true, true, true)
                local id = mode .. ":" .. lhs
                assert(not seen[id], "Duplicate mapping: " .. key[1] .. " (" .. group .. "/" .. (seen[id] or "") .. ")")
                for other, owner in pairs(seen) do
                    if other:sub(1, #mode + 1) == mode .. ":" then
                        local previous = other:sub(#mode + 2)
                        assert(lhs:sub(1, #previous) ~= previous and previous:sub(1, #lhs) ~= lhs,
                            "Mapping prefix conflict: " .. key[1] .. " (" .. group .. "/" .. owner .. ")")
                    end
                end
                seen[id] = group
            end
        end
    end
end

function M.label_alphabet()
    local reserved = {}
    for _, keys in pairs(M.bindings) do
        for _, key in ipairs(keys) do
            if vim.tbl_contains(modes(key), "n") then
                local first = key[1]:match("^<leader>(.)")
                if first then reserved[first] = true end
            end
        end
    end
    for _, key in ipairs(M.groups) do
        local first = key[1]:match("^<leader>(.)")
        if first then reserved[first] = true end
    end
    local alphabet = ("kjwdfasleirutmnhgopqxcvbyABCDEFGHIJKLMNOPQRSTUVWXYZ"):gsub(".", function(char)
        return not reserved[char] and char or ""
    end)
    assert(#alphabet > 0, "No free keys for buffer labels")
    local prefix
    for char in ("zZ"):gmatch(".") do
        if not reserved[char] then prefix = char; break end
    end
    assert(prefix, "Reserve Space z or Space Z for extended buffer labels")
    alphabet = alphabet:gsub(prefix, "")
    return alphabet, prefix
end

function M.setup()
    M.validate()
    M.apply("core")
end

return M
