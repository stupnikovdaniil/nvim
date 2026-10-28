local timing = dofile("tests/bootstrap.lua")
local function check(name, fn)
    fn()
    io.stdout:write("PASS " .. name .. "\n")
end

check("Buffer panel is visible immediately after startup", function()
    assert(require("lazy.core.config").plugins["bufferline.nvim"]._.loaded,
        "Bufferline must load without pressing a shortcut")
    assert(vim.o.showtabline == 2, "Buffer panel is hidden")
    assert(vim.o.tabline:find("nvim_bufferline", 1, true), "Buffer panel renderer is not installed")
    assert(type(nvim_bufferline()) == "string", "Buffer panel cannot render")
end)

check("Lua syntax and centralized mappings", function()
    assert(loadfile("init.lua"))
    for _, path in ipairs(vim.fn.glob("lua/**/*.lua", false, true)) do assert(loadfile(path)) end
    local keys = require("config.keys")
    keys.validate()
    local test = { "<leader>h", function() end }
    table.insert(keys.bindings.core, test)
    assert(not pcall(keys.validate), "Duplicate mapping was not rejected")
    table.remove(keys.bindings.core)
    table.insert(keys.bindings.core, { "<leader>f", function() end })
    assert(not pcall(keys.validate), "Prefix collision was not rejected")
    table.remove(keys.bindings.core)
    local alphabet, prefix = keys.label_alphabet()
    assert(not alphabet:find("h", 1, true) and not alphabet:find("l", 1, true))
    table.insert(keys.bindings.core, { "<leader>k", function() end })
    assert(not keys.label_alphabet():find("k", 1, true), "New reserved key was not excluded")
    table.remove(keys.bindings.core)
    assert(not alphabet:find(prefix, 1, true))
end)

local function new_buffer(name)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, vim.fn.stdpath("cache") .. "/" .. name)
    return buf
end

check("Stable labels, deletion, reuse, and letter navigation", function()
    local labels = require("buffer_labels")
    local first, second, third = new_buffer("first.lua"), new_buffer("second.lua"), new_buffer("third.lua")
    local a, b, c = labels.label(first), labels.label(second), labels.label(third)
    assert(a ~= b and b ~= c and a ~= c)
    vim.api.nvim_set_current_buf(third)
    vim.cmd("BufferLineMovePrev")
    assert(labels.label(third) == c, "Reordering changed label")
    vim.api.nvim_buf_delete(first, { force = true })
    assert(labels.label(second) == b and labels.label(third) == c, "Deleting neighbor changed labels")
    local replacement = new_buffer("replacement.lua")
    assert(labels.label(replacement) == a, "Free label was not reused")
    vim.api.nvim_feedkeys(" " .. b, "xt", false)
    assert(vim.api.nvim_get_current_buf() == second, "Letter selected wrong buffer")
    require("pinbar").pin_current()
    vim.api.nvim_set_current_buf(third)
    vim.api.nvim_feedkeys(" 1", "xt", false)
    assert(vim.api.nvim_get_current_buf() == second, "Pin number selected wrong buffer")
    local many, seen = {}, {}
    for i = 1, 80 do
        local buf = new_buffer("label-" .. i)
        many[#many + 1] = buf
        local label = labels.label(buf)
        assert(not seen[label], "Repeated label")
        seen[label] = true
    end
    local target = many[#many]
    local extended = labels.label(target)
    assert(#extended > 1)
    vim.api.nvim_feedkeys(" " .. extended, "xt", false)
    assert(vim.api.nvim_get_current_buf() == target, "Extended label selected wrong buffer")
    local options = require("lazy.core.config").plugins["bufferline.nvim"].opts.options
    assert(options.numbers({ id = second, ordinal = 999 }) == b, "Panel uses position instead of buffer ID")
end)

check("Independent format scopes and save modes", function()
    require("lazy").load({ plugins = { "conform.nvim" } })
    local formatting = require("config.formatting")
    local buf = new_buffer("format.lua")
    vim.api.nvim_set_current_buf(buf)
    vim.cmd("FormatDisable")
    assert(formatting.disabled() and not vim.g.disable_autoformat)
    vim.cmd("FormatDisable!")
    vim.cmd("FormatEnable")
    assert(formatting.disabled() and not vim.b.disable_autoformat)
    vim.cmd("FormatEnable!")
    assert(not formatting.disabled())
    vim.cmd("FormatDisable")
    formatting.toggle("global")
    formatting.toggle("global")
    assert(formatting.disabled(), "Global toggle erased buffer preference")
    vim.cmd("FormatEnable")
    assert(not formatting.disabled())
    local opts = dofile("lua/plugins/conform.lua")[1].opts
    assert(opts.format_on_save(buf) and not opts.format_after_save(buf))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("x", 512 * 1024 + 1) })
    assert(not opts.format_on_save(buf) and opts.format_after_save(buf))
    vim.cmd("FormatDisable!")
    assert(not opts.format_on_save(buf) and not opts.format_after_save(buf))
    vim.cmd("FormatEnable!")
    assert(type(require("conform").formatters_by_ft.python) == "function")
end)

check("Theme command, LSP settings, and filename escaping", function()
    assert(vim.fn.exists(":ColorUse") == 2)
    assert(vim.lsp.config.lua_ls.settings.Lua.diagnostics.globals[1] == "vim")
    assert(vim.lsp.config.lua_ls.capabilities.textDocument.completion.completionItem.snippetSupport)
    local buf = new_buffer("100%done.lua")
    vim.api.nvim_set_current_buf(buf)
    require("pinbar").pin_current()
    assert(vim.wo.winbar:find("100%%done.lua", 1, true))
end)

check("Plugin configuration after first lazy load", function()
    require("lazy").load({ plugins = {
        "telescope.nvim", "vim-fugitive", "trouble.nvim", "undotree", "which-key.nvim", "lualine.nvim",
    } })
    assert(#timing.errors == 0, table.concat(timing.errors, "\n"))
end)

io.stdout:write(string.format("Config loaded in %.2f ms (headless, installed plugins, network disabled)\n", timing.load_ms))
vim.cmd("qa!")
