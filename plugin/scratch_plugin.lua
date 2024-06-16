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
local scratch_api = require("scratch.api")

local scratch_main = require("scratch")
scratch_main.setup()

vim.api.nvim_create_user_command("Scratch", function(args)
  if args.range > 0 then
    scratch_api.scratch({ content = utils.getSelectedText() })
  else
    scratch_api.scratch()
  end
end, { range = true })

vim.api.nvim_create_user_command("ScratchOpen", scratch_api.openScratch, {})
vim.api.nvim_create_user_command("ScratchOpenFzf", scratch_api.fzfScratch, {})
vim.api.nvim_create_user_command("ScratchWithName", scratch_api.scratchWithName, {})
