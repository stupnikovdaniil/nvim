return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    lazy = false,
    keys = require("config.keys").plugin("bufferline"),
    opts = {
        options = {
            mode = "buffers",
            numbers = function(opts)
                return require("buffer_labels").label(opts.id)
            end,
            close_command = function(bufnr)
                vim.cmd("Bdelete " .. bufnr)
            end,

            name_formatter = function(buf)
                local current_path = buf.path

                if current_path == nil or current_path == "" then
                    return buf.name
                end

                local function normalize(path)
                    return vim.fn.fnamemodify(path, ":p")
                end

                local function basename(path)
                    return vim.fn.fnamemodify(path, ":t")
                end

                local function path_parts(path)
                    path = normalize(path)

                    local parts = {}
                    for part in string.gmatch(path, "[^/]+") do
                        table.insert(parts, part)
                    end

                    return parts
                end

                local function suffix_from_parts(parts, depth)
                    local start = math.max(1, #parts - depth + 1)
                    local suffix = {}

                    for i = start, #parts do
                        table.insert(suffix, parts[i])
                    end

                    return table.concat(suffix, "/")
                end

                local current_abs = normalize(current_path)
                local current_base = basename(current_abs)

                local same_basename_paths = {}

                for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted then
                        local path = vim.api.nvim_buf_get_name(bufnr)

                        if path ~= "" and basename(path) == current_base then
                            table.insert(same_basename_paths, normalize(path))
                        end
                    end
                end

                -- No conflict: show only filename
                if #same_basename_paths <= 1 then
                    return current_base
                end

                local current_parts = path_parts(current_abs)

                -- Increase visible path depth until unique
                for depth = 1, #current_parts do
                    local current_suffix = suffix_from_parts(current_parts, depth)
                    local unique = true

                    for _, other_path in ipairs(same_basename_paths) do
                        if other_path ~= current_abs then
                            local other_parts = path_parts(other_path)
                            local other_suffix = suffix_from_parts(other_parts, depth)

                            if other_suffix == current_suffix then
                                unique = false
                                break
                            end
                        end
                    end

                    if unique then
                        return current_suffix
                    end
                end

                -- Fallback: full path if something pathological happens
                return current_abs
            end,
        },
    },
}
