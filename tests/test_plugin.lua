local child = MiniTest.new_child_neovim()
local new_set = MiniTest.new_set

local function mock()
  local mock_api = {}
  mock_api.scratch = function(opts)
    _G.scratch_opts = opts
  end
  mock_api.openScratch = function()
    print("TODO")
  end
  mock_api.fzfScratch = mock_api.openScratch
  mock_api.scratchWithName = mock_api.openScratch

  package.loaded["scratch.api"] = mock_api
  vim.g.loaded_scratch = 0
  dofile("plugin/scratch_plugin.lua")
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
local T = new_set()
T["Scratch"] = new_set({
  hooks = {
    pre_once = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua_func(mock)
    end,
    post_once = child.stop,
  },
})
local BUFFER_TEXT = {
  "some",
  "text here will be",
  "inserted",
  "now",
}
T["Scratch"]["select_branch"] = new_set({
  parametrize = { { "v" }, { "V" }, { vim.api.nvim_replace_termcodes("<C-V>", true, true, true) } },
})
T["Scratch"]["select_branch"]["parameter"] = new_set({
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
T["Scratch"]["select_branch"]["parameter"]["some_text"] = function(selection_mode, coord)
  child.api.nvim_buf_set_lines(0, 0, -1, false, BUFFER_TEXT)
  child.api.nvim_set_keymap("v", "  ", ":Scratch<CR>")
  select_wise(coord, selection_mode)
  child.type_keys("  ")
  MiniTest.expect.equality(
    table_select(BUFFER_TEXT, coord, selection_mode),
    child.lua_get("_G.scratch_opts").content
  )
end
T["Scratch"]["range_branch"] = new_set()
T["Scratch"]["range_branch"]["lines"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, false, BUFFER_TEXT)
  child.type_keys(":1,2Scratch<CR>")
  MiniTest.expect.equality(
    table_select(BUFFER_TEXT, { 1, 1, 2, 2 }, "V"),
    child.lua_get("_G.scratch_opts").content
  )
end
T["Scratch"]["range_branch"]["selection"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, false, BUFFER_TEXT)
  select_wise({ 1, 1, 3, 3 }, "V")
  child.type_keys(":", "Scratch<CR>")
  MiniTest.expect.equality(
    table_select(BUFFER_TEXT, { 1, 1, 3, 2 }, "V"),
    child.lua_get("_G.scratch_opts").content
  )
end
return T
