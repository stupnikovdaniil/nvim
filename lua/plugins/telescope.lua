return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  keys = require("config.keys").plugin("telescope"),
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- опционально ускорение:
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
  },

  config = function()
    local ok, telescope = pcall(require, "telescope")
    if not ok then return end

    local actions = require("telescope.actions")
    local action_layout = require("telescope.actions.layout")

    telescope.setup({
      defaults = {
        prompt_prefix = "❯ ",
        selection_caret = "➤ ",
        path_display = { "smart" },
        dynamic_preview_title = true,
        mappings = {
          i = {
            ["<C-n>"] = actions.move_selection_next,
            ["<C-p>"] = actions.move_selection_previous,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-o>"] = action_layout.toggle_preview,
            ["<Esc>"] = actions.close,
          },
        },
        file_ignore_patterns = { "%.git/", "node_modules/", "dist/", "build/", "%.cache/", "__pycache__/", "%.venv/", ".tox/" },
        vimgrep_arguments = {
          "rg","--color=never","--no-heading","--with-filename","--line-number","--column",
          "--smart-case","--hidden","--glob","!**/.git/*"
        },
      },
      pickers = {
        find_files = {
          hidden = true, follow = true,
          find_command = { "rg", "--files", "--hidden", "--follow", "--glob", "!.git/*" },
          theme = "dropdown",
        },
        live_grep = { theme = "ivy" },
        buffers = { sort_lastused = true, sort_mru = true, ignore_current_buffer = true, theme = "dropdown" },
        diagnostics = { bufnr = 0, theme = "ivy" },
      },
      extensions = { fzf = { fuzzy = true, case_mode = "smart_case" } },
    })

    pcall(telescope.load_extension, "fzf")
  end,
}
