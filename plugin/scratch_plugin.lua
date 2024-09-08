if vim.g.scratch_load then
  return
end
vim.g.scratch_load = true
vim.g.os_sep = vim.g.os_sep or vim.uv.os_uname().sysname == "Windows_NT" and "\\" or "/"

vim.g.scratch_config = require("scratch.config") ---@type Scratch.ActorConfig

local api = require("scratch.api")
local utils = require("scratch.utils")

vim.api.nvim_create_user_command("Scratch", function(args)
  local fts = vim.g.scratch_config.filetypes
  local scratch_file_dir = vim.g.scratch_config.scratch_file_dir
  if args.range > 0 then
    api.scratchWithFt(scratch_file_dir, fts, { content = utils.getSelectedText() })
  else
    api.scratchWithFt(scratch_file_dir, fts)
  end
end, { range = true })

vim.api.nvim_create_user_command("ScratchOpen", function()
  require("scratch.default_finder").findByNative(vim.g.scratch_config.scratch_file_dir)
end, {})

vim.api.nvim_create_user_command("ScratchOpenTelescope", function()
  require("scratch.default_finder").findByTelescope(vim.g.scratch_config.scratch_file_dir)
end, {})

vim.api.nvim_create_user_command("ScratchOpenTelescopeGrep", function()
  require("scratch.default_finder").findByTelescopeGrep(vim.g.scratch_config.scratch_file_dir)
end, {})

vim.api.nvim_create_user_command("ScratchWithName", function()
  api.scratchWithName(vim.g.scratch_config.scratch_file_dir)
end, {})
