local api = require("api")

local commands = {
	{
		name = "Scratch",
		callback = api.scratch,
	},
	{
		name = "ScratchOpen",
		callback = api.openScratch,
	},
	{
		name = "ScratchOpenFzf",
		callback = api.fzfScratch,
	},
	{
		name = "ScratchWithName",
		callback = api.scratchWithName,
	},
	{
		name = "ScratchCheckConfig",
		callback = api.checkConfig,
	},
}

local M = {}

M.init = function()
	for _, v in ipairs(commands) do
		vim.api.nvim_create_user_command(v.name, v.callback, {})
	end
end

return M
