local M = {}

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

local function getConfigFilePath()
    return vim.fn.stdpath("cache") .. "/scratch.nvim/" .. "config.json"
end

-- Read json file and parse to dictionary
local function readConfigFile()
    local configFilePath = getConfigFilePath()

    -- Write the file if it does not exist
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


return M
