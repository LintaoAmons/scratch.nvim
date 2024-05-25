local json = require("scratch.json")
local slash = require("scratch.utils").Slash()
local utils = require("scratch.utils")

---@alias mode
---| '"n"'
---| '"i"'
---| '"v"'

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
---@field use_telescope boolean
---@field filetype_details Scratch.FiletypeDetails
---@field localKeys Scratch.LocalKeyConfig[]
local default_config = {
  scratch_file_dir = vim.fn.stdpath("cache") .. slash .. "scratch.nvim", -- where your scratch files will be put
  filetypes = { "xml", "go", "lua", "js", "py", "sh" }, -- you can simply put filetype here
  window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
  use_telescope = true,
  filetype_details = { -- or, you can have more control here
    json = {}, -- empty table is fine
    ["k8s.yaml"] = { -- you can have different postfix
      subdir = "learn-k8s", -- and put this in a specific subdir
    },
    go = {
      requireDir = true, -- true if each scratch file requires a new directory
      filename = "main", -- the filename of the scratch file in the new directory
      content = { "package main", "", "func main() {", "  ", "}" },
      cursor = {
        location = { 4, 2 },
        insert_mode = true,
      },
    },
  },
  localKeys = {
    {
      filenameContains = { "sh" },
      LocalKeys = {
        {
          cmd = "<CMD>RunShellCurrentLine<CR>",
          key = "<C-r>",
          modes = { "n", "i", "v" },
        },
      },
    },
  },
}

---@class Scratch.SetupConfig
---@field json_config_path? string
---@field scratch_config? Scratch.Config

local function editConfig()
  vim.cmd(":e " .. vim.g.scratch_json_config_path)
end

---@return Scratch.Config
local function get_and_update_config()
  if not vim.g.scratch_json_config_path then
    utils.log_err("Unable to locate json_config, please restart neovim and try again")
  end

  local ok, json_config =
    pcall(require("scratch.json").read_json_file, vim.g.scratch_json_config_path)
  if not ok then
    local msg = "Can't read the json config at: "
      .. vim.g.scratch_json_config_path
      .. ", please check the config or just delete it"

    utils.log_err(msg)
    error(msg)
  end

  vim.g.scratch_config = json_config
  return vim.g.scratch_config
end

local default_json_config_path = vim.fn.stdpath("config") .. slash .. "scratch_config.json" -- where the json config will be put
vim.g.scratch_config = default_config
vim.g.scratch_json_config_path = default_json_config_path

---@param user_config? Scratch.SetupConfig
local function setup(user_config)
  user_config = user_config or {}

  local json_config_path = user_config and user_config.json_config_path or default_json_config_path
  local json_config
  if json.file_exists(json_config_path) then
    json_config = json.read_json_file(json_config_path)
  else
    json.write_json_file(default_config, json_config_path)
    json_config = json.read_json_file(json_config_path)
  end
  vim.g.scratch_json_config_path = json_config_path

  if not json_config then
    utils.log_err("Can't load the json config, please raise a issue at github")
    return
  end

  local merged_config = utils.merge_tables(user_config.scratch_config or {}, json_config)
  vim.g.scratch_config = merged_config
  json.write_json_file(merged_config, json_config_path)
end

return {
  setup = setup,
  editConfig = editConfig,
  get_and_update_config = get_and_update_config,
}
