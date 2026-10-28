-- ~/.config/nvim/lua/plugins/fugitive.lua
return {
    {
        "tpope/vim-fugitive",
        dependencies = { "tpope/vim-rhubarb" }, -- чтобы :GBrowse открывал ссылку в GitHub/и др.
        cmd = {
            "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit",
            "Gread", "Gwrite", "GMove", "GRename", "GDelete", "GRemove",
            "Ggrep", "Glgrep", "GBrowse", "Gblame",
        },
        keys = require("config.keys").plugin("fugitive"),
    },
}
