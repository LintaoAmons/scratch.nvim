local M = {}

<<<<<<< HEAD
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
-- function M.listDirectoryRecursive(directory)
--   local files = {}
--   local dir_list = vim.fn.readdir(directory)
--
--   for _, file in ipairs(dir_list) do
--     local path = directory .. M.slash .. file
--     if vim.fn.isdirectory(path) == 1 and file ~= "." and file ~= ".." then
--       local subfiles = M.listDirectoryRecursive(path)
--       for _, subfile in ipairs(subfiles) do
--         files[#files + 1] = subfile
--       end
--     elseif vim.fn.isdirectory(path) == 0 then
--       files[#files + 1] = path
--     end
--   end
--
--   return files
-- end

-- Recursively list all files in the specified directory
function M.listDirectoryRecursive(directory)
=======
---@param ft string
---@return string
function M.get_abs_path(ft)
  local filename = os.date("%y-%m-%d_%H-%M-%S") .. "." .. ft
  return filename
end

-- Recursively list all files in the specified directory
function M.scandir(directory)
>>>>>>> d47aefd (refactor+feat(input+selector)!)
  local files = {}
  local next_dir = { directory }
  repeat
    local current_dir = table.remove(next_dir, 1)
    local fd = vim.uv.fs_scandir(current_dir)
    if fd then
      while true do
        local name, typ = vim.uv.fs_scandir_next(fd)
        if name == nil then
          break
        end
<<<<<<< HEAD
        local entry = current_dir .. M.slash .. name
=======
        local entry = current_dir .. vim.g.os_sep .. name
>>>>>>> d47aefd (refactor+feat(input+selector)!)
        if typ == "directory" then
          table.insert(next_dir, entry)
        elseif typ == "file" then
          table.insert(files, entry)
        end
      end
    end
  until #next_dir == 0
  return files
end

--- generate abs filepath
---@param filename string
---@param parentDir string
---@param requiresDir boolean?
---@return string?
function M.genFilepath(filename, parentDir, requiresDir)
  if requiresDir then
<<<<<<< HEAD
    -- local dirName = vim.trim(vim.fn.system("uuidgen")) -- win not support i dont know reason u can actualy use timestamp
    local dirName = parentDir .. M.slash .. os.time()

    local suc, err_n, err_m = vim.uv.fs_mkdir(parentDir, 777) -- linux rwxrwxrwx
    if not suc then
      return vim.notify(err_n .. ": appear " .. err_m, vim.log.levels.ERROR)
    end
    -- vim.fn.mkdir(parentDir .. M.slash .. dirName, "p")
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
=======
    local dirName = parentDir .. vim.g.os_sep .. os.time()
    local suc, err_n, err_m = vim.uv.fs_mkdir(parentDir, 666) -- linux rw_rw_rw_
    if not suc then
      return vim.notify(err_n .. ": appear " .. err_m, vim.log.levels.ERROR)
    end
    return parentDir .. vim.g.os_sep .. dirName .. vim.g.os_sep .. filename
  else
    return parentDir .. vim.g.os_sep .. filename
  end
end

---@return string[]
function M.getSelectedText()
  local sv = vim.fn.getpos("'<")
  local ev = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, sv[2] - 1, ev[2], false)
>>>>>>> d47aefd (refactor+feat(input+selector)!)
  local n = #lines
  if n == 0 then
    return {}
  end
<<<<<<< HEAD
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
function M.write_lines_to_buffer(lines)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
=======
  lines[n] = string.sub(lines[n], 1, sv[3])
  lines[1] = string.sub(lines[1], ev[3])
  return lines
end

---Open window or set current window to new buffer
---@param abs_path string
---@param config? vim.api.keyset.win_config
function M.open_(abs_path, config)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, abs_path)
  if config == nil then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.api.nvim_open_win(buf, true, config)
  end
end

---Make scratch file
---@param abs_path string
---@param win_conf vim.api.keyset.win_config
---@param content? string[]
---@param local_keys? Scratch.LocalKeyConfig
---@param cursor? Scratch.Cursor
function M.scratch(abs_path, win_conf, content, local_keys, cursor)
  M.create_and_edit_file(abs_path, win_conf)
  if content then
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  end
  if cursor then
    M.put_cursor(cursor)
  end
  if local_keys then
    M.register_local_key(local_keys)
  end
end

---@param localKeys Scratch.LocalKeyConfig[]
function M.register_local_key(localKeys)
  for _, key in ipairs(localKeys) do
    for _, namePattern in ipairs(key.filenameContains) do
      if string.find(vim.fn.expand("%:t"), namePattern) ~= nil then
        local buf = vim.api.nvim_get_current_buf()
        for _, localKey in ipairs(key.LocalKeys) do
          vim.keymap.set(localKey.modes, localKey.key, localKey.cmd, {
            noremap = true,
            silent = true,
            nowait = true,
            buffer = buf,
          })
        end
      end
    end
  end
>>>>>>> d47aefd (refactor+feat(input+selector)!)
end

return M
