local config = require("config")
local M = {}

M.test = function()
	vim.notify(config.scratch_file_dir)
end

return M
