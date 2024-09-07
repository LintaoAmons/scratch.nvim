local M = {}
local base_path = vim.fn.stdpath("cache") .. vim.g.os_sep .. "scratch.nvim" .. vim.g.os_sep
---@type Scratch.Actor
local default_config = {
  scratch_file_dir = base_path, -- where your scratch files will be put
  filetypes = { "lua", "js", "py", "sh" }, -- you can simply put filetype here
  win_config = {
    relative = "editor", -- Assuming you want the floating window relative to the editor
    row = 2,
    col = 5,
    width = vim.api.nvim_win_get_width(0) - 10, -- Get the screen width - row * col
    --api_get_option("lines") - 5,
    height = vim.api.nvim_win_get_height(0) - 5, -- Get the screen height - col
    style = "minimal",
    border = "single",
    title = "",
  },
  filetype_details = {},
  localKeys = {},
  manual_text = "MANUAL_INPUT",
}
---@class Scratch.Opts
---@field win_config? vim.api.keyset.win_config
---@field content? string[]
---@field local_keys? Scratch.LocalKeyConfig
---@field cursor? Scratch.Cursor

---@class Scratch.FiletypeDetail
---@field content string[]
---@field cursor Scratch.Cursor
---@field generator fun(scratch_file_dir:string, ft:string): string
--
---@alias Scratch.FiletypeDetails { [string]:Scratch.FiletypeDetail }

---@class Scratch.LocalKey |:h keymap |
---@field mode string|string[]
---@field rhs string | function
---@field lhs string

---@class Scratch.LocalKeyConfig
---@field filenameContains string[] as long as the filename contains any one of the string in the list
---@field LocalKeys Scratch.LocalKey[]
--
---@class Scratch.Cursor
---@field location number[]
---@field insert_mode boolean

---@class Scratch.Config
---@field scratch_file_dir? string
---@field filetypes? string[]
---@field win_config? vim.api.keyset.win_config @see nvim_open_window
---@field filetype_details? Scratch.FiletypeDetails
---@field localKeys? Scratch.LocalKeyConfig[]
---@field manual_text? string

---@param user_config? Scratch.Config
---@return Scratch.Actor
function M.setup(user_config)
  user_config = user_config or {}
  if
    user_config.scratch_file_dir
    and not vim.uv.fs_stat(user_config.scratch_file_dir).type == "directory"
  then
    vim.uv.fs_mkdir(user_config.scratch_file_dir, 666)
  end
  local actor = vim.tbl_deep_extend("force", default_config, user_config)
  return actor
end

return M
