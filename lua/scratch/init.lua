local M = {}

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

---@class Scratch.FiletypeDetail
---@field content string[]
---@field cursor Scratch.Cursor
---@field generator fun(scratch_file_dir:string, ft:string): string
--
---@alias Scratch.FiletypeDetails { [string]:Scratch.FiletypeDetail }

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
  vim.g.scratch_actor = vim.tbl_deep_extend("force", vim.g.scratch_actor, user_config)
  return vim.g.scratch_actor
end

return M
