local M = {}

local default_config = {
    scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
    filetypes = {"json", "xml", "go", "lua", "js", "py", "sh"},
    put_file_in_new_dir = {
        go = "main"
    }
}

local config = default_config

local initDir = function()
    if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
        vim.fn.mkdir(config.scratch_file_dir, "p")
    end
end

local function is_key_in_dict(input, mydict)
    for k, _ in pairs(mydict) do
        if k == input then
            return true
        end
    end
    return false
end

local function is_in_list(item, mylist)
    for _, str in ipairs(mylist) do
        if str == item then
            return true
        end
    end
    return false
end

local function createScratchFile(ft, filename)
    initDir()
    local fullpath
    if filename then
        fullpath = config.scratch_file_dir .. "/" .. filename
    else
        if is_key_in_dict(ft, config.put_file_in_new_dir) then
            local dirName = vim.trim(vim.fn.system('uuidgen'))
            vim.fn.mkdir(config.scratch_file_dir .. "/" .. dirName, "p")
            fullpath = config.scratch_file_dir .. "/" .. dirName .. "/" .. config.put_file_in_new_dir[ft] .. "." .. ft
        else
            fullpath = config.scratch_file_dir .. "/" .. os.date("%H%M%S-%y%m%d") .. "." .. ft
        end
    end
    vim.cmd(":e " .. fullpath)
end

local function selectFiletypeAndDo(func)
    vim.ui.select(config.filetypes, {
        prompt = "Select filetype",
        format_item = function(item)
            return item
        end
    }, function(choosedFt)
        if choosedFt then
            func(choosedFt)
        end
    end)
end

local function listDirectoryRecursive(directory)
    local files = {}
    local dir_list = vim.fn.readdir(directory)
    for _, file in ipairs(dir_list) do
        local path = directory .. '/' .. file
        if vim.fn.isdirectory(path) == 1 and file ~= '.' and file ~= '..' then
            local subfiles = listDirectoryRecursive(path)
            for _, subfile in ipairs(subfiles) do
                files[#files + 1] = subfile
            end
        elseif vim.fn.isdirectory(path) == 0 then
            files[#files + 1] = path
        end
    end
    return files
end

local function getScratchFiles()
    local res = {}
    res = listDirectoryRecursive(config.scratch_file_dir)
    for i, str in ipairs(res) do
        res[i] = string.sub(str, string.len(config.scratch_file_dir) + 2)
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
    vim.ui.input({
        prompt = "Enter the file name: "
    }, function(filename)
        createScratchFile(nil, filename)
    end)
end

M.openScratch = function()
    local files = getScratchFiles()
    -- local files = listDirectoryRecursive(config.scratch_file_dir)

    -- sort the files by their last modified time in descending order
    table.sort(files, function(a, b)
        return vim.fn.getftime(config.scratch_file_dir .. "/" .. a) >
                   vim.fn.getftime(config.scratch_file_dir .. "/" .. b)
    end)

    vim.ui.select(files, {
        prompt = "Select old scratch files",
        format_item = function(item)
            return item
        end
    }, function(chosenFile)
        if chosenFile then
            vim.cmd(":e " .. config.scratch_file_dir .. "/" .. chosenFile)
        end
    end)
end

-- M.openScratch = function()
-- 	vim.ui.select(getScratchFiles(), {
-- 		prompt = "Select old scratch files",
-- 		format_item = function(item)
-- 			return item
-- 		end,
-- 	}, function(chosenFile)
-- 		if chosenFile then
-- 			vim.cmd(":e " .. config.scratch_file_dir .. "/" .. chosenFile)
-- 		end
-- 	end)
-- end

M.fzfScratch = function()
    require("telescope.builtin").live_grep {
        cwd = config.scratch_file_dir
    }
end

return M
