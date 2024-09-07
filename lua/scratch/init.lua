local M = {}
vim.g.os_sep = vim.g.os_sep or vim.fn.has("win32") and "\\" or "/"

local base_path = vim.fn.stdpath("cache") .. vim.g.os_sep .. "scratch.nvim" .. vim.g.os_sep
---@type Scratch.ActorConfig
vim.g.scratch_config = {
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
---@class Scratch.FiletypeDetail
---@field win_config? vim.api.keyset.win_config
---@field content? string[]
---@field local_keys? Scratch.LocalKeyConfig
---@field cursor? Scratch.Cursor
---@field generator? fun(scratch_file_dir:string, ft:string): string

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

---@class Scratch.ActorConfig
---@field scratch_file_dir? string
---@field filetypes? string[]
---@field win_config? vim.api.keyset.win_config @see nvim_open_window
---@field filetype_details? Scratch.FiletypeDetails
---@field localKeys? Scratch.LocalKeyConfig[]
---@field manual_text? string

---@class Scratch.Config
---@field actor_config? Scratch.ActorConfig
---@field default_cmd? boolean

---@param user_config Scratch.ActorConfig
---@return Scratch.Actor
function M.setup_actor(user_config)
  user_config = user_config or {}
  vim.g.scratch_config = vim.tbl_deep_extend("force", vim.g.scratch_config, user_config)
  if
    vim.g.scratch_config.scratch_file_dir
    and not vim.uv.fs_stat(vim.g.scratch_config.scratch_file_dir).type == "directory"
  then
    vim.uv.fs_mkdir(vim.g.scratch_config.scratch_file_dir, 666)
  end
  return vim.g.scratch_config
end

---@param user_config Scratch.Config
---@return Scratch.Actor
function M.setup(user_config)
  local config =
    setmetatable(M.setup_actor(user_config.actor_config), { __index = require("scratch.actor") })
  local utils = require("scratch.utils")
  vim.api.nvim_create_user_command("Scratch", function(args)
    if args.range > 0 then
      config:scratchWithFt({ content = utils.getSelectedText() })
    else
      config:scratchWithFt()
    end
  end, { range = true })
  if user_config.default_cmd ~= false then
    vim.api.nvim_create_user_command("ScratchOpen", function()
      require("scratch.default_finder").findByNative(config.scratch_file_dir)
    end, {})
    vim.api.nvim_create_user_command("ScratchOpenTelescope", function()
      require("scratch.default_finder").findByTelescope(config.scratch_file_dir)
    end, {})
    vim.api.nvim_create_user_command("ScratchOpenTelescopeGrep", function()
      require("scratch.default_finder").findByTelescopeGrep(config.scratch_file_dir)
    end, {})
    vim.api.nvim_create_user_command("ScratchWithName", function()
      config:scratchWithName()
    end, {})
  end
  return config
end
return M
