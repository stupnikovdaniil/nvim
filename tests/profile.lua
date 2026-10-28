local timing = dofile("tests/bootstrap.lua")
local stats = require("lazy").stats()
io.stdout:write(string.format("Config load: %.2f ms; plugins loaded: %d/%d\n", timing.load_ms, stats.loaded, stats.count))
vim.cmd("qa!")
