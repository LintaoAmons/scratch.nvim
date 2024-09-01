local M = {}
local Actor = require("scratch.actor")
---@type Scratch.Actor
vim.g.scratch_actor = vim.g.scratch_actor
  or setmetatable({
    scratch_file_dir = vim.fn.stdpath("cache")
      .. (vim.fn.has("win32") and "\\" or "/")
      .. "scratch.nvim", -- where your scratch files will be put
    filetypes = { "lua", "js", "py", "sh" }, -- you can simply put filetype here
    window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
    file_picker = "fzflua",
    filetype_details = {},
    localKeys = {},
    manual_text = "MANUAL_INPUT",
  }, Actor)

---@alias mode
---| '"n"'
---| '"i"'
---| '"v"'
---
---@alias Scratch.WindowCmd
---| '"popup"'
---| '"vsplit"'
---| '"edit"'
---| '"tabedit"'
---| '"rightbelow vsplit"'

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
---@field scratch_file_dir? string
---@field filetypes? string[]
---@field window_cmd?  Scratch.WindowCmd
---@field file_picker? "fzflua" | "telescope"
---@field filetype_details? Scratch.FiletypeDetails
---@field localKeys? Scratch.LocalKeyConfig[]
---@field manual_text string

-- vim.g.scratch_config = default_config
---@param user_config? Scratch.Config
---@return Scratch.Actor
function M.setup(user_config)
  user_config = user_config or {}
  vim.g.scratch_actor = vim.tbl_deep_extend("force", vim.g.scratch_actor, user_config)
  return vim.g.scratch_actor
  -- vim.g.scratch_config = vim.tbl_deep_extend("force", default_config, user_config or {})
  --   or default_config
end

return M
