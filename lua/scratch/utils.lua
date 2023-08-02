local M = {}

-- Initialize the scratch file directory if it does not exist
function M.initDir(scratch_file_dir)
	if vim.fn.filereadable(scratch_file_dir) == 0 then
		vim.fn.mkdir(scratch_file_dir, "p")
	else
		if vim.fn.isdirectory(scratch_file_dir) ~= 0 then
			vim.notify("Exiting file with the same name: " .. scratch_file_dir)
		end
	end
end

-- Recursively list all files in the specified directory
function M.listDirectoryRecursive(directory)
	local files = {}
	local dir_list = vim.fn.readdir(directory)

	for _, file in ipairs(dir_list) do
		local path = directory .. "/" .. file
		if vim.fn.isdirectory(path) == 1 and file ~= "." and file ~= ".." then
			local subfiles = M.listDirectoryRecursive(path)
			for _, subfile in ipairs(subfiles) do
				files[#files + 1] = subfile
			end
		elseif vim.fn.isdirectory(path) == 0 then
			files[#files + 1] = path
		end
	end

	return files
end

--- generate abs filepath
---@param ft string
---@param filename string
---@param parentDir string
---@param requiresDir boolean
---@return string
function M.genFilepath(ft, filename, parentDir, requiresDir)
	if requiresDir then
		local dirName = vim.trim(vim.fn.system("uuidgen"))
		vim.fn.mkdir(parentDir .. "/" .. dirName, "p")
		return parentDir .. "/" .. dirName .. "/" .. filename .. "." .. ft
	else
		return parentDir .. "/" .. filename .. "." .. ft
	end
end

return M
