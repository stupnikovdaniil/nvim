local M = {}

function M.disabled(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    return vim.g.disable_autoformat == true or vim.b[bufnr].disable_autoformat == true
end

function M.status(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local global = vim.g.disable_autoformat and "OFF" or "ON"
    local buffer = vim.b[bufnr].disable_autoformat and "OFF" or "ON"
    return ("Autoformat: %s (global %s, buffer %s)"):format(M.disabled(bufnr) and "OFF" or "ON", global, buffer)
end

function M.set(scope, enabled)
    assert(scope == "global" or scope == "buffer", "Unknown autoformat scope")
    if scope == "global" then
        vim.g.disable_autoformat = not enabled
    else
        vim.b.disable_autoformat = not enabled
    end
    vim.notify(M.status())
    vim.cmd("redrawstatus")
end

function M.toggle(scope)
    local disabled
    if scope == "global" then
        disabled = vim.g.disable_autoformat
    else
        disabled = vim.b.disable_autoformat
    end
    M.set(scope, disabled == true)
end

function M.setup()
    for _, action in ipairs({ "Enable", "Disable" }) do
        vim.api.nvim_create_user_command("Format" .. action, function(opts)
            M.set(opts.bang and "global" or "buffer", action == "Enable")
        end, { bang = true, desc = action .. " autoformat for buffer (! for all buffers)" })
    end
    vim.api.nvim_create_user_command("FormatStatus", function() vim.notify(M.status()) end, {
        desc = "Show global, buffer, and effective autoformat state",
    })
end

return M
