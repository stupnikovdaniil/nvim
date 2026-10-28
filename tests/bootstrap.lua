-- Isolated runtime: scripts/check.sh points data/cache/state at a temporary folder
-- and links only the already installed plugins. Never install or update anything.
local errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
    if (level or vim.log.levels.INFO) >= vim.log.levels.ERROR then
        errors[#errors + 1] = tostring(message)
    end
    if (level or vim.log.levels.INFO) >= vim.log.levels.WARN then notify(message, level, opts) end
end
vim.go.loadplugins = true
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
assert(vim.uv.fs_stat(vim.fn.stdpath("data") .. "/lazy/lazy.nvim"), "Install plugins before running checks")
local lazy = require("lazy")
local setup = lazy.setup
lazy.setup = function(opts)
    opts.checker = { enabled = false }
    opts.install = { missing = false }
    opts.change_detection = { enabled = false }
    return setup(opts)
end
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/mason.nvim")
require("mason-registry").refresh = function() end
local start = vim.uv.hrtime()
dofile("init.lua")
return { load_ms = (vim.uv.hrtime() - start) / 1e6, errors = errors }
