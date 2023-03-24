if vim.fn.has("nvim-0.7.0") == 0 then
    vim.api.nvim_err_writeln("scratch requires at least nvim-0.7.0.1")
    return
end

-- make sure this file is loaded only once
if vim.g.loaded_scratch == 1 then
    return
end
vim.g.loaded_scratch = 1

-- create any global command that does not depend on user setup
-- usually it is better to define most commands/mappings in the setup function
-- Be careful to not overuse this file!
local scratch = require("scratch")

local commands = {{
    name = "Scratch",
    callback = scratch.scratch
}, {
    name = "ScratchOpen",
    callback = scratch.openScratch
}, {
    name = "ScratchOpenFzf",
    callback = scratch.fzfScratch
}, {
    name = "ScratchWithName",
    callback = scratch.scratchWithName
}, {
    name = "ScratchCheckConfig",
    callback = scratch.checkConfig
},{
	name = "ScratchEditConfig",
	callback = scratch.editConfig
}}

for _, v in ipairs(commands) do
    vim.api.nvim_create_user_command(v.name, v.callback, {})
end
