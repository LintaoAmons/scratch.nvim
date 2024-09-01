local utils = require("scratch.utils")
-- make sure this file is loaded only once
if vim.g.loaded_scratch == 1 then
  return
end
vim.g.loaded_scratch = 1

-- create any global command that does not depend on user setup
-- usually it is better to define most commands/mappings in the setup function
-- Be careful to not overuse this file!

-- TODO: remove those requires
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

vim.api.nvim_create_user_command("Scratch", function(args)
  if args.range > 0 then
    vim.g.scratch_actor:scratch({ content = utils.getSelectedText() })
  else
    vim.g.scratch_actor:scratch({})
  end
end, { range = true })

vim.api.nvim_create_user_command("ScratchOpen", function()
  vim.g.scratch_actor:scratchOpen({})
end, {})
vim.api.nvim_create_user_command("ScratchOpenFzf", function()
  vim.g.scratch_actor:fzfScratch()
end, {})
vim.api.nvim_create_user_command("ScratchWithName", function()
  vim.g.scratch_actor:scratchWithName()
end, {})
