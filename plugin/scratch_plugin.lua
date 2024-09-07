local utils = require("scratch.utils")
-- make sure this file is loaded only once
-- if vim.g.loaded_scratch == 1 then
--   return
-- end
vim.g.loaded_scratch = 1
vim.g.os_sep = vim.g.os_sep or vim.fn.has("win32") and "\\" or "/"

-- create any global command that does not depend on user setup
-- usually it is better to define most commands/mappings in the setup function
-- Be careful to not overuse this file!

-- TODO: remove those requires

local Scratch = require("scratch")
---@type Scratch.Actor
local config = Scratch.setup({})
vim.print(config)
vim.api.nvim_create_user_command("Scratch", function(args)
  if args.range > 0 then
    config:scratchWithFt({ content = utils.getSelectedText() })
  else
    config:scratchWithFt()
  end
end, { range = true })

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
  vim.g.scratch_actor:scratchWithName()
end, {})
