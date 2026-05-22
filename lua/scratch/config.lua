local utils = require("scratch.utils")
local slash = utils.Slash()

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
---@field requireDir? boolean -- DEPRECATED: use subdir = true instead
---@field subdir? string|boolean -- subdirectory path, true for unique, "%" in path for unique segment
---@field content? string[]
---@field cursor? Scratch.Cursor
--
---@class Scratch.FiletypeDetails
---@field [string] Scratch.FiletypeDetail

---@class Scratch.PickerKeys
---@field delete? string
---@field toggle_mode? string

---@class Scratch.Config
---@field scratch_file_dir string
---@field filetypes string[]
---@field window_cmd  string
---@field file_picker? "fzflua" | "telescope" | "snacks" | nil
---@field filetype_details Scratch.FiletypeDetails
---@field localKeys Scratch.LocalKeyConfig[]
---@field hooks Scratch.Hook[]
---@field picker_keys? Scratch.PickerKeys
---@field picker_snacks_multi? boolean
local default_config = {
  scratch_file_dir = vim.fn.stdpath("cache") .. slash .. "scratch.nvim", -- where your scratch files will be put
  filetypes = { "lua", "js", "py", "sh" }, -- you can simply put filetype here
  window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
  file_picker = "snacks",
  filetype_details = {},
  localKeys = {},
  hooks = {},
  picker_keys = {
    delete = "<C-x>",
    toggle_mode = "<C-f>",
  },
  picker_snacks_multi = false,
}

---@type Scratch.Config
vim.g.scratch_config = default_config

---@param user_config? Scratch.Config
local function setup(user_config)
  user_config = user_config or {}

  vim.g.scratch_config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Warn about deprecated requireDir
  for ft, detail in pairs(vim.g.scratch_config.filetype_details or {}) do
    if detail.requireDir then
      vim.notify(
        "[scratch.nvim] filetype_details."
          .. ft
          .. '.requireDir is deprecated. Use subdir = true | "example-dir/%" instead.',
        vim.log.levels.WARN
      )
    end
  end

  -- Validate file_picker
  local cfg = vim.g.scratch_config
  local valid_pickers = { fzflua = true, telescope = true, snacks = true }
  if cfg.file_picker and not valid_pickers[cfg.file_picker] then
    vim.notify(
      '[scratch.nvim] Invalid file_picker "'
        .. cfg.file_picker
        .. '". Valid options: "fzflua", "telescope", "snacks", or nil.',
      vim.log.levels.WARN
    )
  end
end

---@param ft string
---@param config_data Scratch.Config
---@return string
local function get_abs_path(ft, config_data)
  local detail = config_data.filetype_details[ft]

  local filename = (detail and detail.filename)
    or tostring(os.date("%y-%m-%d_%H-%M-%S")) .. "." .. ft

  local parentDir = config_data.scratch_file_dir
  local needs_unique = false

  if detail then
    local subdir = detail.subdir
    if detail.requireDir or subdir == true then
      needs_unique = true
    elseif type(subdir) == "string" then
      if subdir:find("%%") then
        parentDir = parentDir .. slash .. subdir:gsub("%%", utils.genUniqueDirName())
      else
        parentDir = parentDir .. slash .. subdir
      end
    end
  end

  vim.fn.mkdir(parentDir, "p")
  return utils.genFilepath(filename, parentDir, needs_unique)
end

return {
  setup = setup,
  get_abs_path = get_abs_path,
}
