local slash = require("scratch.utils").Slash()
local utils = require("scratch.utils")
local triger = require("scratch.hooks").trigger_points

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
---@field hooks? table<Scratch.Trigger,Scratch.Hook>
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
---@field hooks Scratch.Hook[]
local default_config = {
  scratch_file_dir = vim.fn.stdpath("cache") .. slash .. "scratch.nvim", -- where your scratch files will be put
  filetypes = { "lua", "js", "py", "sh", "MANUAL_INPUT" }, -- you can simply put filetype here
  window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
  file_picker = "fzflua",
  filetype_details = {
    ["MANUAL_INPUT"] = {
      hooks = {
        ---@see: https://github.com/mfussenegger/nvim-dap/blob/66d33b7585b42b7eac20559f1551524287ded353/lua/dap/ui.lua#L55
        [triger.POST_CHOICE] = function()
          local co = coroutine.running()
          local confirmer = function(input)
            coroutine.resume(co, input)
          end
          confirmer = vim.schedule_wrap(confirmer)
          vim.ui.input({ prompt = "Input filetype: " }, confirmer)
          return coroutine.yield()
        end,
      },
    },
  },
  localKeys = {},
  hooks = {
    [triger.PRE_CHOICE] = {
      function(filetypes)
        local co = coroutine.running()
        vim.ui.select(filetypes, {
          prompt = "Select filetype",
          format_item = function(item)
            return item
          end,
        }, function(choosedFt)
          coroutine.resume(co, choosedFt)
        end)
        return coroutine.yield()
      end,
    },
    [triger.PRE_OPEN] = {
      function(opts)
        local files, scratch_file_dir = opts.files, opts.scratch_file_dir
        local co = coroutine.running()

        -- sort the files by their last modified time in descending order
        table.sort(files, function(a, b)
          return vim.fn.getftime(scratch_file_dir .. slash .. a)
            > vim.fn.getftime(scratch_file_dir .. slash .. b)
        end)
        vim.ui.select(files, {
          prompt = "Select old scratch files",
          format_item = function(item)
            return item
          end,
        }, function(chosenFile)
          coroutine.resume(co, chosenFile)
        end)
        return coroutine.yield()
      end,
    },
  },
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
    parentDir = parentDir .. slash .. subdir
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
