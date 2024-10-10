---@class Scratch.FiletypeDetail
---@field win_config? vim.api.keyset.win_config
---@field content? string[]
---@field local_keys? Scratch.LocalKeyConfig
---@field cursor? Scratch.Cursor
---@field generator? fun(scratch_file_dir:string, ft:string): string, string

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
---@field scratch_file_dir string
---@field filetypes string[]
---@field win_config? vim.api.keyset.win_config @see nvim_open_window `nil` open buffer at current win
---@field generator fun(scratch_file_dir:string, ft:string): string, string
---@field filetype_details? Scratch.FiletypeDetails
---@field localKeys? Scratch.LocalKeyConfig
---@field manual_text? string
---@field scratchOpen fun(self:Scratch.ActorConfig)

---@class Scratch.Config
---@field actor_config? Scratch.ActorConfig
---@field default_cmd? boolean

local base_path = vim.fn.stdpath("cache") .. vim.g.os_sep .. "scratch.nvim" .. vim.g.os_sep
return { ---@type Scratch.Actor
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
  scratchOpen = require("scratch.default_finder").findByNative, -- Maybe will be used for compilation
  filetype_details = {},
  generator = function(base_dir, ft)
    local filename = os.date("%y-%m-%d_%H-%M-%S") .. "." .. ft
    return base_dir .. filename, filename
  end,

  manual_text = "MANUAL_INPUT",
}
