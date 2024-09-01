local utils = require("scratch.utils")

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
---@field filename? string
---@field requireDir? boolean -- TODO: conbine requireDir and subdir into one table
---@field subdir? string
---@field content? string[]
---@field cursor? Scratch.Cursor
--
---@class Scratch.FiletypeDetails
---@field [string] Scratch.FiletypeDetail

---@class Scratch.Config
---@field scratch_file_dir string
---@field filetypes string[]
---@field window_cmd  string
---@field file_picker? "fzflua" | "telescope" | nil
---@field filetype_details Scratch.FiletypeDetails
---@field localKeys Scratch.LocalKeyConfig[]
local default_config = {
  scratch_file_dir = vim.fn.stdpath("cache") .. utils.slash .. "scratch.nvim", -- where your scratch files will be put
  filetypes = { "lua", "js", "py", "sh" }, -- you can simply put filetype here
  window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
  file_picker = "fzflua",
  filetype_details = {},
  localKeys = {},
}

---@type Scratch.Config
vim.g.scratch_config = default_config

---@param user_config? Scratch.Config
local function setup(user_config)
  user_config = user_config or {}

  vim.g.scratch_config = vim.tbl_deep_extend("force", default_config, user_config or {})
    or default_config
end

---@param ft string
---@return string
local function get_abs_path(ft)
  local config_data = vim.g.scratch_config

  local filename = config_data.filetype_details[ft] and config_data.filetype_details[ft].filename
    or tostring(os.date("%y-%m-%d_%H-%M-%S")) .. "." .. ft

  local parentDir = config_data.scratch_file_dir
  local subdir = config_data.filetype_details[ft] and config_data.filetype_details[ft].subdir
  if subdir ~= nil then
    parentDir = parentDir .. utils.slash .. subdir
  end
  vim.fn.mkdir(parentDir, "p")

  local require_dir = config_data.filetype_details[ft]
      and config_data.filetype_details[ft].requireDir
    or false

  return utils.genFilepath(filename, parentDir, require_dir)
end

return {
  setup = setup,
  get_abs_path = get_abs_path,
}
