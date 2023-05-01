local M = {}

local configDir      = vim.fn.stdpath("cache") .. "/scratch.nvim/"
local configFilePath = configDir .. "config.json"

local default_config = {
    scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
    filetypes = {"xml", "go", "lua", "js", "py", "sh"}, -- you can simply put filetype here
    filetype_details = { -- you can have more control here
        json = {}, -- not required to put this to `filetypes` table, even though you still can
        go = {
            requireDir = true,
            filename = "main",
            content = {"package main", "", "func main() {", "  ", "}"},
            cursor = {
                location = {4, 2},
                insert_mode = true
            }
        }
    }
}

-- Create the config directory if not exist.
local initConfigDir = function()
    if vim.fn.isdirectory(configDir) == 0 then
        vim.fn.mkdir(configDir, "p")
    end
end

-- Read json file and parse to dictionary
local function getConfig()
    initConfigDir()
    -- write file if the file is not exist
    if vim.fn.filereadable(configFilePath) == 0 then
        local file = io.open(configFilePath, "w")
        file:write(vim.fn.json_encode(default_config))
        file:close()
    end
    local file = io.open(configFilePath, "r")
    local json_data = file:read("*all")
    file:close()
    return vim.fn.json_decode(json_data)
end

local config = getConfig()

local function getScratchFileDir()
    if config.scratch_file_dir == nil then
        return vim.fn.stdpath("cache") .. "/scratch.nvim"
    elseif string.sub(config.scratch_file_dir, 1, 1) ~= "/" then
        return vim.fn.stdpath("cache") .. "/" .. config.scratch_file_dir
    else
        return config.scratch_file_dir
    end
end


local initDir = function()
    if vim.fn.isdirectory(getScratchFileDir()) == 0 then
        vim.fn.mkdir(getScratchFileDir(), "p")
    end
end

-- open the config write in nvim current buffer
local function editConfig()
    vim.cmd(":e " .. configFilePath)
end

M.editConfig = editConfig


local function getFiletypes()
    local combined_filetypes = {}
    for _, ft in ipairs(config.filetypes) do
        if not vim.tbl_contains(combined_filetypes, ft) then
            table.insert(combined_filetypes, ft)
        end
    end

    for ft, _ in pairs(config.filetype_details) do
        if not vim.tbl_contains(combined_filetypes, ft) then
            table.insert(combined_filetypes, ft)
        end
    end
    return combined_filetypes
end

local function write_lines_to_buffer(lines)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function requiresDir(ft)
    return config.filetype_details[ft] and config.filetype_details[ft].requireDir or false
end

local function hasDefaultContent(ft)
    local details = default_config.filetype_details[ft]
    return details and details.content and #details.content > 1
end

local function genFilename(ft)
    return config.filetype_details[ft] and config.filetype_details[ft].filename or os.date("%H%M%S-%y%m%d")
end

local function hasCursorPosition(ft)
    local details = default_config.filetype_details[ft]
    return details and details.cursor and #details.cursor.location > 1
end

local function genFilepath(ft, filename)
    local fullpath
    if filename then
        fullpath = getScratchFileDir() .. "/" .. filename
    else
        if requiresDir(ft) then
            local dirName = vim.trim(vim.fn.system('uuidgen'))
            vim.fn.mkdir(getScratchFileDir() .. "/" .. dirName, "p")
            fullpath = getScratchFileDir() .. "/" .. dirName .. "/" .. genFilename(ft) .. "." .. ft
        else
            fullpath = getScratchFileDir() .. "/" .. genFilename(ft) .. "." .. ft
        end
    end
    return fullpath
end

local function createScratchFile(ft, filename)
    initDir()
    local fullpath = genFilepath(ft, filename)
    vim.cmd(":e " .. fullpath)

    if hasDefaultContent(ft) then
        write_lines_to_buffer(config.filetype_details.go.content)
    end

    if hasCursorPosition(ft) then
        vim.api.nvim_win_set_cursor(0, config.filetype_details.go.cursor.location)
        if config.filetype_details.go.cursor.insert_mode then
            vim.api.nvim_feedkeys('a', 'n', true)
        end
    end
end

local function selectFiletypeAndDo(func)
    local filetypes = getFiletypes()
    vim.ui.select(filetypes, {
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
    res = listDirectoryRecursive(getScratchFileDir())
    for i, str in ipairs(res) do
        res[i] = string.sub(str, string.len(getScratchFileDir()) + 2)
    end
    return res
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

    -- sort the files by their last modified time in descending order
    table.sort(files, function(a, b)
        return vim.fn.getftime(getScratchFileDir() .. "/" .. a) >
                   vim.fn.getftime(getScratchFileDir() .. "/" .. b)
    end)

    vim.ui.select(files, {
        prompt = "Select old scratch files",
        format_item = function(item)
            return item
        end
    }, function(chosenFile)
        if chosenFile then
            vim.cmd(":e " .. getScratchFileDir() .. "/" .. chosenFile)
        end
    end)
end

M.fzfScratch = function()
    require("telescope.builtin").live_grep {
        cwd = getScratchFileDir()
    }
end

return M
