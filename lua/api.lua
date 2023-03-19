local M = {}

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
        insert_mode = true
      }
    },
  }
}

local config = default_config

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

local initDir = function()
  if vim.fn.isdirectory(config.scratch_file_dir) == 0 then
    vim.fn.mkdir(config.scratch_file_dir, "p")
  end
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
    fullpath = config.scratch_file_dir .. "/" .. filename
  else
    if requiresDir(ft) then
      local dirName = vim.trim(vim.fn.system('uuidgen'))
      vim.fn.mkdir(config.scratch_file_dir .. "/" .. dirName, "p")
      fullpath = config.scratch_file_dir ..
          "/" .. dirName .. "/" .. genFilename(ft) .. "." .. ft
    else
      fullpath = config.scratch_file_dir .. "/" .. genFilename(ft) .. "." .. ft
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

M.fzfScratch = function()
  require("telescope.builtin").live_grep {
    cwd = config.scratch_file_dir
  }
end

return M
