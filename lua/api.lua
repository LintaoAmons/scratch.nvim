local M = {}

local default_config = {
  scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
  filetypes = { "json", "xml", "go", "lua", "js", "py", "sh" },
  filetypes_require_dir = {
    go = {
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

  for ft, _ in pairs(config.filetypes_require_dir) do
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

local function is_key_in_dict(input, mydict)
  for k, _ in pairs(mydict) do
    if k == input then
      return true
    end
  end
  return false
end

local function require_new_dir(ft)
  return is_key_in_dict(ft, config.filetypes_require_dir)
end

local function genFilepath(ft, filename)
  local fullpath
  if filename then
    fullpath = config.scratch_file_dir .. "/" .. filename
  else
    if require_new_dir() then
      local dirName = vim.trim(vim.fn.system('uuidgen'))
      vim.fn.mkdir(config.scratch_file_dir .. "/" .. dirName, "p")
      fullpath = config.scratch_file_dir ..
          "/" .. dirName .. "/" .. config.filetypes_require_dir[ft].filename .. "." .. ft
    else
      fullpath = config.scratch_file_dir .. "/" .. os.date("%H%M%S-%y%m%d") .. "." .. ft
    end
  end
  return fullpath
end

local function createScratchFile(ft, filename)
  initDir()
  local fullpath = genFilepath(ft, filename)
  vim.cmd(":e " .. fullpath)

  write_lines_to_buffer(config.filetypes_require_dir.go.content)
  vim.api.nvim_win_set_cursor(0, config.filetypes_require_dir.go.cursor.location)
  if config.filetypes_require_dir.go.cursor.insert_mode then
    vim.api.nvim_feedkeys('a', 'n', true)
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
