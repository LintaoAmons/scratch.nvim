local s = require("scratch")

local commands = {
	{
		name = "Scratch",
		callback = s.scratch,
	},
	{
		name = "OpenScratch",
		callback = s.openScratch,
	},
	{
		name = "ScratchWithName",
		callback = s.scratchWithName,
	},
	{
		name = "CheckConfig",
		callback = s.checkConfig,
	},
}

local M = {}

M.init = function()
	for _, v in ipairs(commands) do
		vim.api.nvim_create_user_command(v.name, v.callback, {})
	end
end

return M
