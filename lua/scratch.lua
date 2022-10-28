local config = require("config")
local M = {}

M.test = function()
	vim.fn.mkdir(config.scratch_file_dir, "p")
	vim.notify(config.scratch_file_dir .. " created")

	-- if not vim.fn.isdirectory(config.scratch_file_dir) then
	-- 	vim.fn.mkdir(config.scratch_file_dir, "p")
	-- 	vim.notify(config.scratch_file_dir .. " created")
	-- else
	-- 	vim.notify(config.scratch_file_dir .. " already exists")
	-- end
end

return M
