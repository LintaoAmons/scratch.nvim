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
  local mode = vim.api.nvim_get_mode().mode
  local opts
  if mode ~= "n" then
    opts = { content = utils.getSelectedText(".", mode) }
  elseif args.range > 0 then
    opts = { content = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, true) }
  end
  scratch_api.scratch(opts)
end, { range = true })

vim.api.nvim_create_user_command("ScratchOpen", scratch_api.openScratch, {})
vim.api.nvim_create_user_command("ScratchOpenFzf", scratch_api.fzfScratch, {})
vim.api.nvim_create_user_command("ScratchWithName", scratch_api.scratchWithName, {})
