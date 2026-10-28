-- Temporary, visible-row hints for Neo-tree v3.x.
-- Labels use the user's preferred home-row letters and are scoped to this view.
local M = {}

local ns = vim.api.nvim_create_namespace("NeoTreeFileHints")
local alphabet = "kjwdfasleirutmnhgopqzxcvby" -- each letter once

local function make_label(index, width)
  local base = #alphabet
  local label = ""
  for _ = 1, width do
    local digit = index % base + 1
    label = alphabet:sub(digit, digit) .. label
    index = math.floor(index / base)
  end
  return label
end

function M.jump(state, open_after)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].filetype ~= "neo-tree" or not state or not state.tree then return end

  local renderer = require("neo-tree.ui.renderer")
  local bounds = vim.api.nvim_win_call(win, function()
    return { vim.fn.line("w0"), vim.fn.line("w$") }
  end)
  local top, bottom = bounds[1], bounds[2]
  local rows = {}
  for _, node in ipairs(renderer.get_all_visible_nodes(state.tree)) do
    local _, line = state.tree:get_node(node:get_id())
    if line and line >= top and line <= bottom then
      rows[#rows + 1] = { id = node:get_id(), line = line }
    end
  end
  table.sort(rows, function(a, b) return a.line < b.line end)
  if #rows == 0 then return end

  local width, capacity = 1, #alphabet
  while capacity < #rows do
    width, capacity = width + 1, capacity * #alphabet
  end
  local candidates = {}
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, row in ipairs(rows) do
    local label = make_label(i - 1, width)
    candidates[label] = row
    vim.api.nvim_buf_set_extmark(buf, ns, row.line - 1, 0, {
      virt_text = { { label .. " ", "Search" } },
      virt_text_pos = "overlay",
      priority = 200,
    })
  end
  vim.cmd("redraw")

  local prefix, target = "", nil
  local ok = pcall(function()
    for _ = 1, width do
      local key = vim.fn.getcharstr()
      if key == "\27" or key == "\3" then return end
      prefix = prefix .. key
      local possible = false
      for label, row in pairs(candidates) do
        if label:sub(1, #prefix) == prefix then
          possible = true
          if label == prefix then target = row end
        end
      end
      if not possible then return end
      if target then break end
    end
  end)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if not ok or not target or not vim.api.nvim_win_is_valid(win) then return end

  vim.api.nvim_set_current_win(win)
  renderer.focus_node(state, target.id)
  if open_after then state.commands.open(state) end
end

return M
