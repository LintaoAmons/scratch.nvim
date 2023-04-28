local M = {}

local CONFIG_FILE_PATH = vim.fn.stdpath("cache") .. "/scratch.nvim/" .. "configFilePath"

local default_config = {
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

local function getConfigFilePath()
    -- read CONFIG_FILE_PATH content as the filepath and return
    local file = io.open(CONFIG_FILE_PATH, "r")
    local filepath = file:read("*all")
    file:close()

    return filepath
end

local function validate_abspath(path)
    -- Check if path starts with a forward slash
    if string.sub(path, 1, 1) ~= "/" then
        return false
    end

    -- Check if path contains any invalid characters
    if string.match(path, "[^%w/%.%-%_]+") then
        return false
    end

    -- Check if path ends with a forward slash
    if string.sub(path, -1) == "/" then
        return false
    end

    -- Check if path contains any double forward slashes
    if string.match(path, "//") then
        return false
    end

    -- Check path must be file type
    if vim.fn.isdirectory(path) == 1 then
        return false
    end

    -- If all checks pass, return true
    return true
end

local function initProcess()
    print("start init Process")
    -- ask user to input the abspath of scratch file dir
    local scratch_file_dir = vim.fn.input("Please input the abspath of scratch file dir: ")
    if validate_abspath(scratch_file_dir) == false then
        print("invalid path. Path must be absolute and must be a file type not directory")
        return
    end
    -- write the scratch_file_dir into CONFIG_FILE_PATH file
    local file = io.open(CONFIG_FILE_PATH, "w")
    file:write(scratch_file_dir)
    file:close()
    -- write default_config into user defined config file
    local configFilePath = getConfigFilePath()
    -- create file and dir of the path is not exist
    vim.fn.mkdir(vim.fn.fnamemodify(configFilePath, ":h"), "p")
    local file = io.open(configFilePath, "w")
    file:write(vim.fn.json_encode(default_config))
    file:close()
    print("init Process done")
end

-- Read json file and parse to dictionary
local function readConfigFile()
    local configFilePath = getConfigFilePath()
    -- print("readConfigFile: " .. configFilePath)

    -- Write the file if it does not exist
    if vim.fn.filereadable(configFilePath) == 0 then
        initProcess()
    end

    local file = io.open(configFilePath, "r")
    local json_data = file:read("*all")
    file:close()

    return vim.fn.json_decode(json_data)
end

-- Expose getConfig function
function M.getConfig()
    return readConfigFile()
end

-- Expose editConfig function
function M.editConfig()
    vim.cmd(":e " .. getConfigFilePath())
end

function M.checkConfig()
    vim.notify(vim.inspect(readConfigFile()))
end

function M.initConfigInterceptor(fn)

    function withInterceptor()
        if vim.fn.filereadable(CONFIG_FILE_PATH) == 0 then
            initProcess()
        else
            if validate_abspath(getConfigFilePath()) then
                return fn()
            else
                initProcess()
            end
        end
    end

    return withInterceptor
end

return M
