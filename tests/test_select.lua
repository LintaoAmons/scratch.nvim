local child = MiniTest.new_child_neovim()
local getSelectedText
local function table_select(text, coord, selection_mode)
  local lines = {}
  local start_row, start_col, end_row, end_col = coord[1], coord[2], coord[3], coord[4]
  if selection_mode == "v" then
    table.insert(lines, text[start_row]:sub(start_col))
    for i = start_row + 1, end_row do
      table.insert(lines, text[i])
    end
    local ind = end_row - start_row + 1
    lines[ind] = lines[ind]:sub(1, end_col)
  elseif selection_mode == "V" then
    for i = start_row, end_row do
      table.insert(lines, text[i])
    end
  elseif selection_mode == vim.api.nvim_replace_termcodes("<C-V>", true, true, true) then
    for i = start_row, end_row do
      table.insert(lines, text[i]:sub(start_col, end_col))
    end
  end
  return lines
end
local select_wise = function(coord, selection_mode)
  local vim = child
  local start_row, start_col, end_row, end_col = coord[1], coord[2], coord[3], coord[4]
  local mode = vim.api.nvim_get_mode()
  if mode.mode ~= "n" then
    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, true, true)
    vim.api.nvim_cmd({ cmd = "normal", bang = true, args = { esc } }, {})
    vim.api.nvim_cmd({ cmd = "normal", bang = true, args = { esc } }, {})
  end
  selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)
  vim.api.nvim_cmd({ cmd = "normal", bang = true, args = { selection_mode } }, {})

  vim.api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

-- local function old_real(mark, mode)
--   local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
--   local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
--
--   local lines = vim.fn.getline(csrow, cerow)
--   local n = #lines
--   if n <= 0 then
--     return {}
--   end
--   lines[n] = string.sub(lines[n], 1, cecol)
--   lines[1] = string.sub(lines[1], cscol)
--   return lines
-- end

local new_set = MiniTest.new_set
local T = new_set({
  parametrize = { { "v" }, { "V" }, { vim.api.nvim_replace_termcodes("<C-V>", true, true, true) } },
})
T["param"] = new_set({
  parametrize = {
    {
      { 1, 1, 1, 4 },
    },
    {
      { 1, 2, 1, 4 },
    },
    {
      { 2, 1, 3, 4 },
    },
    {
      { 1, 1, 2, 2 },
    },
    {
      { 1, 1, 1, 1 },
    },
    {
      { 1, 1, 4, 4 },
    },
  },
})
local BUFFER_TEXT = {
  "some",
  "text here will be",
  "inserted",
  "now",
}
-- T["param"]["old"] = new_set({
--   hooks = {
--     pre_case = function()
--       child.restart({ "-u", "scripts/minimal_init.lua" })
--       child.api.nvim_buf_set_lines(0, 0, -1, false, BUFFER_TEXT)
--     end,
--     post_case = function()
--       child.stop()
--     end,
--   },
-- })
T["param"]["new"] = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.api.nvim_buf_set_lines(0, 0, -1, false, BUFFER_TEXT)
      getSelectedText = require("scratch.utils").getSelectedText
    end,
    post_case = function()
      child.stop()
    end,
  },
  n_retry = 2,
})
-- T["param"]["old"]["not_workd"] = function(selection_mode, coord)
--   select_wise(coord, selection_mode)
--   MiniTest.expect.no_equality(
--     table_select(BUFFER_TEXT, coord, selection_mode),
--     child.lua_func(old_real)
--   )
-- end
T["param"]["new"]["workd"] = function(selection_mode, coord)
  select_wise(coord, selection_mode)
  MiniTest.expect.equality(
    table_select(BUFFER_TEXT, coord, selection_mode),
    child.lua_func(getSelectedText, ".", selection_mode)
  )
end
-- T["param"]["old"]["at_command"] = function(selection_mode, coord)
--   select_wise(coord, selection_mode)
--   child.type_keys(":")
--   MiniTest.expect.equality(
--     table_select(BUFFER_TEXT, coord, selection_mode),
--     child.lua_func(old_real)
--   )
-- end
T["param"]["new"]["at_command"] = function(selection_mode, coord)
  select_wise(coord, selection_mode)
  child.type_keys(":")
  MiniTest.add_note("|1>--- " .. vim.inspect(child.fn.getpos("'>")))
  MiniTest.add_note("|2>--- " .. vim.inspect(child.fn.getpos(".")))
  MiniTest.expect.equality(
    table_select(BUFFER_TEXT, coord, selection_mode),
    child.lua_func(getSelectedText, "'>", selection_mode)
  )
end
T["new"] = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.api.nvim_buf_set_lines(0, 0, -1, false, {})
      getSelectedText = require("scratch.utils").getSelectedText
    end,
    post_case = function()
      child.stop()
    end,
  },
  parametrize = { { { 1, 1, 1, 1 } } },
})
T["new"]["empty_file"] = function(selection_mode, coord)
  select_wise(coord, selection_mode)
  local pos1 = child.fn.getpos("v")
  local pos2 = child.fn.getpos(".")
  MiniTest.add_note("|1>--- " .. vim.inspect(pos1))
  MiniTest.add_note("|2>--- " .. vim.inspect(pos2))
  MiniTest.expect.equality(
    table_select({ "" }, coord, selection_mode),
    child.lua_func(getSelectedText, ".", selection_mode)
  )
end

return T
