local M = {}
local config = require("scratch.config")
local slash = require("scratch.utils").Slash()
local utils = require("scratch.utils")

local function editFile(fullpath)
  local config_data = config.getConfig()
  local cmd = config_data.window_cmd or "edit"
  vim.api.nvim_command(cmd .. " " .. fullpath)
end

local function write_lines_to_buffer(lines)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function hasDefaultContent(ft)
  local config_data = config.getConfig()
  return config_data.filetype_details[ft]
    and config_data.filetype_details[ft].content
    and #config_data.filetype_details[ft].content > 0
end

local function hasCursorPosition(ft)
  local config_data = config.getConfig()
  return config_data.filetype_details[ft]
    and config_data.filetype_details[ft].cursor
    and #config_data.filetype_details[ft].cursor.location > 0
end

---@param filename string
function M.createScratchFileByName(filename)
  local config_data = config.getConfig()
  local scratch_file_dir = config_data.scratch_file_dir
  utils.initDir(scratch_file_dir)

  local fullpath = scratch_file_dir .. slash .. filename
  editFile(fullpath)
end

local function registerLocalKey()
  local localKeys = config.getLocalKeys()
  if localKeys and #localKeys > 0 then
    for _, key in ipairs(localKeys) do
      for _, namePattern in ipairs(key.filenameContains) do
        if utils.filenameContains(namePattern) then
          utils.setLocalKeybindings(key.LocalKeys)
        end
      end
    end
  end
end

---@param ft string
function M.createScratchFileByType(ft)
  local config_data = config.getConfig()
  local parentDir = config_data.scratch_file_dir
  utils.initDir(parentDir)

  local subdir = config.getConfigSubDir(ft)
  if subdir ~= nil then
    parentDir = parentDir .. slash .. subdir
    utils.initDir(parentDir)
  end

  local fullpath =
    utils.genFilepath(config.getConfigFilename(ft), parentDir, config.getConfigRequiresDir(ft))
  editFile(fullpath)

  registerLocalKey()

  if hasDefaultContent(ft) then
    write_lines_to_buffer(config_data.filetype_details[ft].content)
  end

  if hasCursorPosition(ft) then
    vim.api.nvim_win_set_cursor(0, config_data.filetype_details[ft].cursor.location)
    if config_data.filetype_details[ft].cursor.insert_mode then
      vim.api.nvim_feedkeys("a", "n", true)
    end
  end
end

local function getFiletypes()
  local config_data = config.getConfig()
  local combined_filetypes = {}
  for _, ft in ipairs(config_data.filetypes) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end

  for ft, _ in pairs(config_data.filetype_details) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end
  return combined_filetypes
end

local function selectFiletypeAndDo(func)
  local filetypes = getFiletypes()

  vim.ui.select(filetypes, {
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
  local config_data = config.getConfig()
  local scratch_file_dir = config_data.scratch_file_dir
  local res = {}
  res = utils.listDirectoryRecursive(scratch_file_dir)
  for i, str in ipairs(res) do
    res[i] = string.sub(str, string.len(scratch_file_dir) + 2)
  end
  return res
end

function M.scratchPad(mode, startLine, endLine)
  if not config.checkInit() then
    config.initConfig()
  end

  local absPath = vim.fn.expand("%:p")

  local content = {
    "================ " .. os.date("%Y-%m-%d %H:%M:%S") .. " | " .. absPath .. " ================",
    "",
  }
  if mode == "v" then
    local lines = vim.fn.getline(startLine, endLine)

    for i = 1, #lines do
      table.insert(content, lines[i])
    end
  end
  table.insert(content, "")
  table.insert(content, "")

  local config_data = config.getConfig()
  -- TODO: config the pad path
  local padPath = config_data.pad_path or config_data.scratch_file_dir .. slash .. "scratchPad.md"
  -- TODO: config: pad open in split or current window or float window
  editFile(padPath)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  vim.api.nvim_put(content, "", false, true)
end

function M.scratch()
  selectFiletypeAndDo(M.createScratchFileByType)
end

function M.scratchWithName()
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    M.createScratchFileByName(filename)
  end)
end

local function open_scratch_telescope()
  local status, telescope_builtin = pcall(require, "telescope.builtin")
  if not status then
    vim.notify(
      'ScrachOpenFzf needs telescope.nvim or you can add `"use_telescope: false"` into your config file'
    )
    return
  end

  telescope_builtin.find_files({
    cwd = config.getConfig().scratch_file_dir,
    attach_mappings = function(prompt_bufnr, map)
      map("n", "dd", function()
        require("scratch.telescope_actions").delete_item(prompt_bufnr)
      end)

      return true
    end,
  })
end

local function open_scratch_vim_ui()
  local files = getScratchFiles()
  local config_data = config.getConfig()
  local scratch_file_dir = config_data.scratch_file_dir

  -- sort the files by their last modified time in descending order
  table.sort(files, function(a, b)
    return vim.fn.getftime(scratch_file_dir .. slash .. a)
      > vim.fn.getftime(scratch_file_dir .. slash .. b)
  end)

  vim.ui.select(files, {
    prompt = "Select old scratch files",
    format_item = function(item)
      return item
    end,
  }, function(chosenFile)
    if chosenFile then
      editFile(scratch_file_dir .. slash .. chosenFile)
      registerLocalKey()
    end
  end)
end

function M.openScratch()
  print(config.get_use_telescope())
  if config.get_use_telescope() then
    open_scratch_telescope()
  else
    open_scratch_vim_ui()
  end
end

return M
