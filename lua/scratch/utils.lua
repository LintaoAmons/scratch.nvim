local M = {}

function M.Slash()
    local slash = "/"
    if vim.fn.has("win32") == 1 then
        slash = "\\"
    end
    return slash
end

local slash = M.Slash()

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
		local path = directory .. slash .. file
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
---@param filename string
---@param parentDir string
---@param requiresDir boolean
---@return string
function M.genFilepath(filename, parentDir, requiresDir)
	if requiresDir then
		local dirName = vim.trim(vim.fn.system("uuidgen"))
		vim.fn.mkdir(parentDir .. slash .. dirName, "p")
		return parentDir .. slash .. dirName .. slash .. filename
	else
		return parentDir .. slash .. filename
	end
end

---@param localKey Scratch.LocalKey
function M.setLocalKeybindings(localKeys)
	for _, localKey in ipairs(localKeys) do
		vim.keymap.set(localKey.modes, localKey.key, localKey.cmd, {
			noremap = true,
			silent = true,
			nowait = true,
			buffer = vim.api.nvim_get_current_buf(),
		})
	end
end

---@param substr string
---@return boolean
function M.filenameContains(substr)
	local s = vim.fn.expand("%:t")
	if string.find(s, substr) then
		return true
	else
		return false
	end
end

local table_length = function(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

---@return string[]
function M.getSelectedText()
	local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
	local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))

	local lines = vim.fn.getline(csrow, cerow)
	local n = table_length(lines)
	if n <= 0 then
		return {}
	end
	lines[n] = string.sub(lines[n], 1, cecol)
	lines[1] = string.sub(lines[1], cscol)
	return lines
end

return M
