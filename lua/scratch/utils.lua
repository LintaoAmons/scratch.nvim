local M = {}

---@param ft string
---@param base_dir string
---@return string
---@return string
function M.get_abs_path(base_dir, ft)
  local filename = os.date("%y-%m-%d_%H-%M-%S") .. "." .. ft
  return base_dir .. filename, filename
end

-- Recursively list all files in the specified directory
function M.scandir(directory)
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
        local entry = current_dir .. name
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
---@param filename string
---@param ft string
---@param opts Scratch.FiletypeDetail
---	win_config vim.api.keyset.win_config
--- content? string[]
--- local_keys? Scratch.LocalKeyConfig
--- cursor? Scratch.Cursor
function M.scratch(abs_path, filename, ft, opts)
  local win_config, content, local_keys, cursor =
    opts.win_config, opts.content, opts.local_keys, opts.cursor

  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, abs_path)
  vim.api.nvim_set_option_value("filename", ft, { buf = buf })

  if win_config == nil then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.api.nvim_open_win(buf, true, win_config)
  end

  if content then
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  end

  if cursor then
    vim.api.nvim_win_set_cursor(0, cursor.location)
    if cursor.insert_mode then
      vim.api.nvim_feedkeys("a", "n", true)
    end
  end

  if local_keys then
    local lkey = local_keys.LocalKeys
    local lcon = local_keys.filenameContains
    for i = 1, #lcon do
      for j = 1, #lkey do
        if filename:find(lcon[i]) then
          local k = lkey[j]
          vim.keymap.set(k.mode, k.lhs, k.rhs, {
            noremap = true,
            silent = true,
            nowait = true,
            buffer = buf,
          })
        end
      end
    end
  end
end

-- ---@param localKeys Scratch.LocalKeyConfig[]
-- function M.register_local_key(localKeys)
--   local filename = vim.fn.expand("%:t")
--   for _, key in ipairs(localKeys) do
--     for _, namePattern in ipairs(key.filenameContains) do
--       if string.find(filename, namePattern) ~= nil then
--         local buf = vim.api.nvim_get_current_buf()
--         for _, localKey in ipairs(key.LocalKeys) do
--           vim.keymap.set(localKey.mode, localKey.lhs, localKey.rhs, {
--             noremap = true,
--             silent = true,
--             nowait = true,
--             buffer = buf,
--           })
--         end
--       end
--     end
--   end
-- end

return M
