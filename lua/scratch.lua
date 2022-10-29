local config = require("config")
local M = {}

M.initDir = function()
	if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
		vim.fn.mkdir(config.scratch_file_dir, "p")
		vim.notify(config.scratch_file_dir .. " created")
	else
		vim.notify(config.scratch_file_dir .. " already exists")
	end
end

local function selectFiletype()
	local selectedFt = "md"
	vim.ui.select(config.filetypes, {
		prompt = "Select filetype",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		selectedFt = choice
	end)
	return selectedFt
end

M.createOrOpenScratchFile = function()
	local ft = selectFiletype()
	vim.notify(ft)
end

return M
