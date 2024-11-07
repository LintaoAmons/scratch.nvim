local M = {}

local function Slash()
  local slash = "/"
  if vim.fn.has("win32") == 1 then
    slash = "\\"
  end
  return slash
end

local slash = Slash()

-- Recursively list all files in the specified directory
local function listDirectoryRecursive(directory)
  local files = {}
  local dir_list = vim.fn.readdir(directory)

  for _, file in ipairs(dir_list) do
    local path = directory .. slash .. file
    if vim.fn.isdirectory(path) == 1 and file ~= "." and file ~= ".." then
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

--- generate abs filepath
---@param filename string
---@param parentDir string
---@param requiresDir boolean
---@return string
local function genFilepath(filename, parentDir, requiresDir)
  if requiresDir then
    local dirName = vim.trim(vim.fn.system("uuidgen"))
    vim.fn.mkdir(parentDir .. slash .. dirName, "p")
    return parentDir .. slash .. dirName .. slash .. filename
  else
    return parentDir .. slash .. filename
  end
end

---@param localKeys Scratch.LocalKey[]
local function setLocalKeybindings(localKeys)
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
local function filenameContains(substr)
  local s = vim.fn.expand("%:t")
  if string.find(s, substr) then
    return true
  else
    return false
  end
end

local table_length = function(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

local getregion = vim.fn.has("nvim-0.10") == 1 and vim.fn.getregion
  or function(pos1, pos2, opts)
    local lines = {}
    local start_row, start_col, end_row, end_col = pos1[2], pos1[3], pos2[2], pos2[3]
    local selection_mode = opts.type
    local text = vim.api.nvim_buf_get_lines(0, start_row, end_row, true)
    end_row = end_row - start_row + 1
    start_row = 1
    if selection_mode == "v" then
      table.insert(lines, text[1]:sub(start_col))
      for i = start_row + 1, end_row do
        table.insert(lines, text[i])
      end
      lines[end_row] = lines[end_row]:sub(1, end_col)
    elseif selection_mode == "V" then
      for i = start_row, end_row do
        table.insert(lines, text[i])
      end
    elseif selection_mode == vim.api.nvim_replace_termcodes("<C-V>", true, true, true) then
      for i = start_row, end_row do
        table.insert(lines, text[i]:sub(start_col, end_col))
      end
    end
    return lines
  end
---@return string[]
local function getSelectedText(mark, mode)
  mode = vim.api.nvim_replace_termcodes(mode, true, true, true)
  return getregion(vim.fn.getpos("v"), vim.fn.getpos(mark), { type = mode })
end

---@param msg string
local function log_err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "easy-commands.nvim" })
end

---@param title string
---@return {buf: integer, win: integer}
local function new_popup_window(title)
  local popup_buf = vim.api.nvim_create_buf(false, false)

  local opts = {
    relative = "editor", -- Assuming you want the floating window relative to the editor
    row = 2,
    col = 5,
    width = vim.api.nvim_get_option("columns") - 10, -- Get the screen width
    height = vim.api.nvim_get_option("lines") - 5, -- Get the screen height
    style = "minimal",
    border = "single",
    title = "",
  }

  local win = vim.api.nvim_open_win(popup_buf, true, opts)
  return {
    buf = popup_buf,
    win = win,
  }
end

return {
  Slash = Slash,
  listDirectoryRecursive = listDirectoryRecursive,
  genFilepath = genFilepath,
  setLocalKeybindings = setLocalKeybindings,
  filenameContains = filenameContains,
  getSelectedText = getSelectedText,
  log_err = log_err,
  new_popup_window = new_popup_window,
}
