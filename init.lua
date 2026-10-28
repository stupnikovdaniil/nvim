require("config.lazy")
vim.o.foldenable = false
local opt = vim.opt

-- Курсор и интерфейс
opt.guicursor = ""        -- фиксированный курсор (не моргает)
opt.mouse = ""            -- отключаем мышь
opt.number = true         -- показывать номера строк
opt.relativenumber = true -- относительные номера

-- Табуляция и отступы
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true   -- пробелы вместо табов
opt.smartindent = true -- автоотступы

-- Поиск
opt.hlsearch = false -- не оставлять подсветку после поиска
opt.incsearch = true -- подсвечивать совпадения при вводе

-- Файлы и история
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undofile = true
if vim.fn.isdirectory(opt.undodir:get()[1]) == 0 then
    vim.fn.mkdir(opt.undodir:get()[1], "p", 448) -- 0700
end

-- Отображение
opt.wrap = false
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.colorcolumn = "80"
opt.termguicolors = true
opt.updatetime = 250 -- частота обновления (влияет на LSP/diagnostics)

require("config.keys").setup()
require("pinbar").setup()
require("buffer_labels").setup()
