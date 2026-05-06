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
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- ~/.local/share/nvim/undo

-- Отображение
opt.wrap = false
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.colorcolumn = "80"
opt.termguicolors = true
opt.updatetime = 250 -- частота обновления (влияет на LSP/diagnostics)

-- Быстрое переключение line numbers
vim.keymap.set("n", "<leader>n", function()
    opt.number = not opt.number:get()
    opt.relativenumber = opt.number:get()
end, { desc = "Toggle line numbers" })


vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, desc = "Window down" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, desc = "Window right" })
vim.keymap.set("n", "<C-u>", "<C-w>k", { silent = true, desc = "Window up" })


vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize window sizes" })

vim.keymap.set("n", "<", "<cmd>vertical resize -5<CR>", { silent = true, desc = "Shrink width" })
vim.keymap.set("n", ">", "<cmd>vertical resize +5<CR>", { silent = true, desc = "Expand width" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw explorer" })

-- Pinbar
require("pinbar").setup()

-- Пин текущего файла
vim.keymap.set("n", "<leader>pp", function()
    require("pinbar").pin_current()
end, { silent = true, desc = "Pin current file to window panel" })

-- Переход по номеру панели: <leader>1..9  (Alt занят AeroSpace)
for i = 1, 9 do
    vim.keymap.set("n", ("<leader>%d"):format(i), function()
        require("pinbar").goto_index(i)
    end, { silent = true, desc = ("Go to pin #%d"):format(i) })
end

-- Удаление вкладки по номеру: <leader>d1..9
for i = 1, 9 do
    vim.keymap.set("n", ("<leader>d%d"):format(i), function()
        require("pinbar").remove_index(i)
    end, { silent = true, desc = ("Remove pin #%d"):format(i) })
end
