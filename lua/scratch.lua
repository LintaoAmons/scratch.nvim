local config = require("config")
local M = {}

M.test = function()
	if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
		vim.fn.mkdir(config.scratch_file_dir, "p")
		vim.notify(config.scratch_file_dir .. " created")
	else
		vim.notify(config.scratch_file_dir .. " already exists")
	end
end

return M
