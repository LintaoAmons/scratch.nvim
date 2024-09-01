local M = {}

-- NOTE: no need
-- local function Slash()
--   local slash = "/"
--   if vim.fn.has("win32") == 1 then
--     slash = "\\"
--   end
--   return slash
-- end

M.slash = vim.fn.has("win32") and "\\" or "/"

-- Initialize the scratch file directory if it does not exist
-- TODO: remove this function
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
    local path = directory .. M.slash .. file
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
    vim.fn.mkdir(parentDir .. M.slash .. dirName, "p")
    return parentDir .. M.slash .. dirName .. M.slash .. filename
  else
    return parentDir .. M.slash .. filename
  end
end

---@param localKeys Scratch.LocalKey[]
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
  return string.find(s, substr) ~= nil
end

-- local table_length = function(T)
--   local count = 0
--   for _ in pairs(T) do
--     count = count + 1
--   end
--   return count
-- end

---@return string[]
function M.getSelectedText()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  --NOTE: perfomance eq but this always string[]
  -- local lines = vim.api.nvim_buf_get_lines(0, csrow, cerow, false)
  local lines = vim.fn.getline(csrow, cerow)
  ---@cast lines string[]
  local n = #lines
  if n == 0 then
    return {}
  end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)
  return lines
end

---@param msg string
function M.log_err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "easy-commands.nvim" })
end

---@param title string
---@return {buf: integer, win: integer}
function M.new_popup_window(title)
  local popup_buf = vim.api.nvim_create_buf(false, false)
  -- NOTE: vim.api.nvim_get_option -- depracated
  -- local api_get_option = vim.api.nvim_get_option or vim.api.nvim_get_option_value
  local opts = {
    relative = "editor", -- Assuming you want the floating window relative to the editor
    row = 2,
    col = 5,
    --api_get_option("columns") - 10, (row * col?)
    width = vim.api.nvim_win_get_width(0) - 10, -- Get the screen width
    --api_get_option("lines") - 5,
    height = vim.api.nvim_win_get_height(0) - 5, -- Get the screen height
    style = "minimal",
    border = "single",
    title = title,
  }

  local win = vim.api.nvim_open_win(popup_buf, true, opts)
  return {
    buf = popup_buf,
    win = win,
  }
end
return M
-- return {
--   Slash = Slash,
--   initDir = initDir,
--   listDirectoryRecursive = listDirectoryRecursive,
--   genFilepath = genFilepath,
--   setLocalKeybindings = setLocalKeybindings,
--   filenameContains = filenameContains,
--   getSelectedText = getSelectedText,
--   log_err = log_err,
--   new_popup_window = new_popup_window,
-- }
