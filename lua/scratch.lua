local M = {}

M.default_config = {
	scratch_file_dir = vim.env.HOME .. "/scratch.nvim",
	filetypes = { "json", "xml", "go", "lua", "js", "py" },
}

M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", M.default_config, user_config or {})
end

M.checkConfig = function()
	vim.notify(vim.inspect(M.config))
end

M.initDir = function()
	if vim.fn.isdirectory(M.config.scratch_file_dir) == 0 then
		vim.fn.mkdir(M.config.scratch_file_dir, "p")
	end
end

local function createScratchFile(ft, filename)
	M.initDir()
	local fullpath
	if filename then
		fullpath = M.config.scratch_file_dir .. "/" .. filename
	else
		fullpath = M.config.scratch_file_dir .. "/" .. os.date("%H%M%S-%y") .. "." .. ft
	end
	vim.cmd(":e " .. fullpath)
end

local function selectFiletypeAndDo(func)
	vim.ui.select(M.config.filetypes, {
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

M.scratch = function()
	selectFiletypeAndDo(createScratchFile)
end

M.scratchWithName = function()
	vim.ui.input({ prompt = "Enter the file name" }, function(filename)
		createScratchFile(nil, filename)
	end)
end

local function getScratchFiles()
	local res = {}
	for k, v in vim.fs.dir(M.config.scratch_file_dir) do
		if v == "file" then
			res[#res + 1] = k
		end
	end
	return res
end

M.openScratch = function()
	vim.ui.select(getScratchFiles(), {
		prompt = "Select old scratch files",
		format_item = function(item)
			return item
		end,
	}, function(chosenFile)
		if chosenFile then
			vim.cmd(":e " .. M.config.scratch_file_dir .. "/" .. chosenFile)
		end
	end)
end

M.setup()

return M
