local M = {}

local default_config = {
	scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
	filetypes = { "json", "xml", "go", "lua", "js", "py", "sh" },
}

local config = default_config

local initDir = function()
	if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
		vim.fn.mkdir(config.scratch_file_dir, "p")
	end
end

local function createScratchFile(ft, filename)
	initDir()
	local fullpath
	if filename then
		fullpath = config.scratch_file_dir .. "/" .. filename
	else
		fullpath = config.scratch_file_dir .. "/" .. os.date("%H%M%S-%y%m%d") .. "." .. ft
	end
	vim.cmd(":e " .. fullpath)
end

local function selectFiletypeAndDo(func)
	vim.ui.select(config.filetypes, {
		prompt = "Select filetype",
		format_item = function(item)
			return item
		end,
	}, function(choosedFt)
		if choosedFt then
			func(choosedFt)
		end
	end)
end

local function getScratchFiles()
	local res = {}
	for k, v in vim.fs.dir(config.scratch_file_dir) do
		if v == "file" then
			res[#res + 1] = k
		end
	end
	return res
end

M.setup = function(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

M.checkConfig = function()
	vim.notify(vim.inspect(config))
end

M.scratch = function()
	selectFiletypeAndDo(createScratchFile)
end

M.scratchWithName = function()
	vim.ui.input({ prompt = "Enter the file name: " }, function(filename)
		createScratchFile(nil, filename)
	end)
end

M.openScratch = function()
	vim.ui.select(getScratchFiles(), {
		prompt = "Select old scratch files",
		format_item = function(item)
			return item
		end,
	}, function(chosenFile)
		if chosenFile then
			vim.cmd(":e " .. config.scratch_file_dir .. "/" .. chosenFile)
		end
	end)
end

M.fzfScratch = function ()
	require("telescope.builtin").live_grep {cwd = config.scratch_file_dir}
end

return M
