local config = require("config").config
local M = {}

M.setup = function(cfg)
	config = vim.tbl_extend("force", config, cfg)
end

M.initDir = function()
	if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
		vim.fn.mkdir(config.scratch_file_dir, "p")
		vim.notify(config.scratch_file_dir .. " created")
	else
		vim.notify(config.scratch_file_dir .. " already exists")
	end
end

local function createOrOpenFile(ft)
	local datetime = string.gsub(vim.fn.system("date +'%Y%m%d-%H%M%S'"), "\n", "")
	local filename = config.scratch_file_dir .. "/" .. datetime .. "." .. ft
	vim.cmd(":e " .. filename)
end

local function selectFiletypeAndDo(func)
	vim.ui.select(config.filetypes, {
		prompt = "Select filetype",
		format_item = function(item)
			return item
		end,
	}, function(choosedFt)
		func(choosedFt)
	end)
end

M.createOrOpenScratchFile = function()
	selectFiletypeAndDo(createOrOpenFile)
end

return M
