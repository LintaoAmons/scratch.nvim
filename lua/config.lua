local M = {}

-- CONFIG_FILE_PATH act like a flag to check if user already init the plugin or not
-- inside only contains the info about the path where user put there's config json content
local CONFIG_FILE_FLAG_PATH = vim.fn.stdpath("cache") .. "/scratch.nvim/" .. "configFilePath"
local DEFAULT_CONFIG_PATH = vim.fn.stdpath("config") .. "/scratch_config.json"
local logErr = function(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "easy-commands.nvim" })
end

local default_config = {
	scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
	filetypes = { "xml", "go", "lua", "js", "py", "sh" }, -- you can simply put filetype here
	filetype_details = { -- you can have more control here
		json = {}, -- not required to put this to `filetypes` table, even though you still can
		go = {
			requireDir = true,
			filename = "main",
			content = { "package main", "", "func main() {", "  ", "}" },
			cursor = {
				location = { 4, 2 },
				insert_mode = true,
			},
		},
		["gp.md"] = {
			cursor = {
				location = { 12, 2 },
				insert_mode = true,
			},
			content = {
				"# topic: ?",
				"",
				'- model: {"top_p":1,"temperature":0.7,"model":"gpt-3.5-turbo-16k"}',
				"- file: placeholder",
				"- role: You are a general AI assistant.",
				"",
				"Write your queries after 🗨:. Run :GpChatRespond to generate response.",
				"",
				"---",
				"",
				"🗨:",
				"",
			},
		},
	},
}

local function getConfigFilePath()
	-- read CONFIG_FILE_PATH content as the filepath and return
	local file = io.open(CONFIG_FILE_FLAG_PATH, "r")
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

	-- if already exist check if it's a file
	if vim.fn.filereadable(path) == 1 then
		if vim.fn.isdirectory(path) == 1 then
			return false
		end
	end

	-- If all checks pass, return true
	return true
end

---Init the plugin
---@param force boolean
local function initProcess(force)
	-- if CONFIG_FILE_PATH file exist, don't need init
	if vim.fn.filereadable(CONFIG_FILE_FLAG_PATH) == 1 and force ~= true then
		if validate_abspath(getConfigFilePath()) then
			return
		else
			logErr("Invalid path. Please rm `" .. CONFIG_FILE_FLAG_PATH .. "`and try again")
		end
	end

	-- ask user to input the abspath of scratch file dir
	local configFilePath =
		vim.fn.input("Where you want to put your configuration file (abspath): ", DEFAULT_CONFIG_PATH)
	if validate_abspath(configFilePath) == false then
		vim.notify("invalid path. Path must be abspath and must be file type")
		return
	end

	-- write the scratch_file_dir into CONFIG_FILE_PATH file
	local dir_path = vim.fn.fnamemodify(CONFIG_FILE_FLAG_PATH, ":h")
	if vim.fn.isdirectory(dir_path) == 0 then
		vim.fn.mkdir(dir_path, "p")
	end

	local file = io.open(CONFIG_FILE_FLAG_PATH, "w")
	file:write(configFilePath)
	file:close()

	-- write default_config into user defined config file
	-- create file and dir of the path is not exist

	vim.fn.mkdir(vim.fn.fnamemodify(configFilePath, ":h"), "p")
	file = io.open(configFilePath, "w")
	file:write(vim.fn.json_encode(default_config))
	file:close()
	vim.notify("Init done, your config file will be at " .. configFilePath)
end

-- Read json file and parse to dictionary
local function readConfigFile()
	local configFilePath = getConfigFilePath()

	local file = io.open(configFilePath, "r")
	local json_data = file:read("*all")
	file:close()

	return vim.fn.json_decode(json_data)
end

---comment
---@return {}
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
	local function withInterceptor()
		if vim.fn.filereadable(CONFIG_FILE_FLAG_PATH) == 0 then
			vim.notify("here")
			vim.notify(CONFIG_FILE_FLAG_PATH)
			initProcess(false)
		else
			if validate_abspath(getConfigFilePath()) then
				return fn()
			else
				initProcess(false)
			end
		end
	end

	return withInterceptor
end

function M.initConfig()
	initProcess(true)
end

return M
