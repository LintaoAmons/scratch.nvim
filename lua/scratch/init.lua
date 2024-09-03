local M = {}

---@alias mode
---| '"n"'
---| '"i"'
---| '"v"'
---
<<<<<<< HEAD
---@alias Scratch.WindowCmd
---| '"popup"'
---| '"vsplit"'
---| '"edit"'
---| '"tabedit"'
---| '"rightbelow vsplit"'
=======
>>>>>>> d47aefd (refactor+feat(input+selector)!)

---@class Scratch.LocalKey
---@field cmd string
---@field key string
---@field modes mode[]

---@class Scratch.LocalKeyConfig
---@field filenameContains string[] as long as the filename contains any one of the string in the list
---@field LocalKeys Scratch.LocalKey[]
--
---@class Scratch.Cursor
---@field location number[]
---@field insert_mode boolean

---@class Scratch.FiletypeDetail
---@field filename? string -- I don't quite understand the use case? Every time replace?
---@field requireDir? boolean -- TODO: conbine requireDir and subdir into one table
---@field subdir? string
---@field content? string[]
---@field cursor? Scratch.Cursor
--
---@alias Scratch.FiletypeDetails { [string]:Scratch.FiletypeDetail }

-- Note: What?
-- M.scratchByType = require("scratch.api").createScratchFileByType
-- M.scratchByName = require("scratch.api").createScratchFileByName
-- M.scratchOpen = require("scratch.api").openScratch
-- M.scratchFzf = require("scratch.api").fzfScratch

---@class Scratch.Config
---@field base_dir? string
---@field filetypes? string[]
<<<<<<< HEAD
---@field window_cmd?  Scratch.WindowCmd
=======
---@field window? vim.api.keyset.win_config @see nvim_open_window
>>>>>>> d47aefd (refactor+feat(input+selector)!)
---@field file_picker? "fzflua" | "telescope"
---@field filetype_details? Scratch.FiletypeDetails
---@field localKeys? Scratch.LocalKeyConfig[]
---@field manual_text? string

---@param user_config? Scratch.Config
---@return Scratch.Actor
function M.setup(user_config)
  user_config = user_config or {}
<<<<<<< HEAD
=======
  if user_config.base_dir and not vim.uv.fs_stat(user_config.base_dir).type == "directory" then
    vim.uv.fs_mkdir(user_config.base_dir, 666)
  end
>>>>>>> d47aefd (refactor+feat(input+selector)!)
  vim.g.scratch_actor = vim.tbl_deep_extend("force", vim.g.scratch_actor, user_config)
  return vim.g.scratch_actor
  -- vim.g.scratch_config = vim.tbl_deep_extend("force", default_config, user_config or {})
  --   or default_config
end

return M
