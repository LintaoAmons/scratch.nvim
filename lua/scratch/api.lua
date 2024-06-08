local slash = require("scratch.utils").Slash()
local utils = require("scratch.utils")
local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")
local MANUAL_INPUT_OPTION = "MANUAL_INPUT"

local function editFile(fullpath)
  local cmd = vim.g.scratch_config.window_cmd or "edit"
  vim.api.nvim_command(cmd .. " " .. fullpath)
end

local function write_lines_to_buffer(lines)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function hasDefaultContent(ft)
  local config_data = vim.g.scratch_config
  return config_data.filetype_details[ft]
    and config_data.filetype_details[ft].content
    and #config_data.filetype_details[ft].content > 0
end

local function hasCursorPosition(ft)
  local config_data = vim.g.scratch_config
  return config_data.filetype_details[ft]
    and config_data.filetype_details[ft].cursor
    and #config_data.filetype_details[ft].cursor.location > 0
end

---@param filename string
local function createScratchFileByName(filename)
  local config_data = vim.g.scratch_config
  local scratch_file_dir = config_data.scratch_file_dir
  utils.initDir(scratch_file_dir)

  local fullpath = scratch_file_dir .. slash .. filename
  editFile(fullpath)
end

local function registerLocalKey()
  local localKeys = vim.g.scratch_config.localKeys
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
---@return string
local function getConfigFilename(ft)
  local config_data = vim.g.scratch_config
  return config_data.filetype_details[ft] and config_data.filetype_details[ft].filename
    or tostring(os.date("%y-%m-%d_%H-%M-%S")) .. "." .. ft
end

---@param ft string
---@return boolean
local function does_require_dir(ft)
  local config_data = vim.g.scratch_config
  return config_data.filetype_details[ft] and config_data.filetype_details[ft].requireDir or false
end

---@param ft string
local function createScratchFileByType(ft)
  local config_data = vim.g.scratch_config
  local parentDir = config_data.scratch_file_dir
  utils.initDir(parentDir)

  local subdir = config_data.filetype_details[ft] and config_data.filetype_details[ft].subdir
  if subdir ~= nil then
    parentDir = parentDir .. slash .. subdir
    utils.initDir(parentDir)
  end

  local fullpath = utils.genFilepath(getConfigFilename(ft), parentDir, does_require_dir(ft))
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

---@return string[]
local function get_all_filetypes()
  local config_data = vim.g.scratch_config
  local combined_filetypes = {}
  for _, ft in ipairs(config_data.filetypes or {}) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end

  for ft, _ in pairs(config_data.filetype_details or {}) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end

  table.insert(combined_filetypes, MANUAL_INPUT_OPTION)
  return combined_filetypes
end

local function select_filetype_then_do(func)
  local filetypes = get_all_filetypes()

  vim.ui.select(filetypes, {
    prompt = "Select filetype",
    format_item = function(item)
      return item
    end,
  }, function(choosedFt)
    if choosedFt then
      if choosedFt == MANUAL_INPUT_OPTION then
        vim.ui.input({ prompt = "Input filetype: " }, function(ft)
          func(ft)
        end)
      else
        func(choosedFt)
      end
    end
  end)
end

local function get_scratch_files()
  local config_data = vim.g.scratch_config
  local scratch_file_dir = config_data.scratch_file_dir
  local res = {}
  res = utils.listDirectoryRecursive(scratch_file_dir)
  for i, str in ipairs(res) do
    res[i] = string.sub(str, string.len(scratch_file_dir) + 2)
  end
  return res
end

local function scratch()
  select_filetype_then_do(createScratchFileByType)
end

local function scratchWithName()
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
      createScratchFileByName(filename)
    end
  end)
end

local function open_scratch_telescope()
  local config_data = vim.g.scratch_config

  if not telescope_status then
    vim.notify(
      'ScrachOpen needs telescope.nvim or you can just add `"use_telescope: false"` into your config file ot use native select ui'
    )
    return
  end

  telescope_builtin.find_files({
    cwd = config_data.scratch_file_dir,
    attach_mappings = function(prompt_bufnr, map)
      -- TODO: user can customise keybinding
      map("n", "dd", function()
        require("scratch.telescope_actions").delete_item(prompt_bufnr)
      end)

      return true
    end,
  })
end

local function open_scratch_vim_ui()
  local files = get_scratch_files()
  local config_data = vim.g.scratch_config

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

local function openScratch()
  local config_data = vim.g.scratch_config

  if config_data.use_telescope then
    open_scratch_telescope()
  else
    open_scratch_vim_ui()
  end
end

local function fzfScratch()
  local config_data = vim.g.scratch_config
  if not telescope_status then
    vim.notify("ScrachOpenFzf needs telescope.nvim")
    return
  end

  telescope_builtin.live_grep({
    cwd = config_data.scratch_file_dir,
  })
end

return {
  createScratchFileByName = createScratchFileByName,
  createScratchFileByType = createScratchFileByType,
  scratch = scratch,
  scratchWithName = scratchWithName,
  openScratch = openScratch,
  fzfScratch = fzfScratch,
}
