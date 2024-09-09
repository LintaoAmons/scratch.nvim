local utils = require("scratch.utils")

local M = {}

---@param scratch_file_dir string
---@param filename string
---@param opts? Scratch.FiletypeDetail
function M.scratchByName(scratch_file_dir, filename, opts)
  ---@type string[]
  local paths = {}
  opts = opts or {}

  -- Split filename to dirs
  for sub_path in filename:gmatch("([^" .. vim.g.os_sep .. "]+)") do
    table.insert(paths, sub_path)
  end
  local p_len = #paths

  -- Create all subdir
  for i = 1, p_len - 1 do
    scratch_file_dir = scratch_file_dir .. paths[i] ---@as string
    local stat, err_m = vim.uv.fs_stat(scratch_file_dir)
    if err_m then
      return vim.notify(err_m, vim.log.levels.ERROR)
    end
    if not stat or stat.type ~= "directory" then
      local suc, err_me = vim.uv.fs_mkdir(scratch_file_dir, 666)
      if not suc then
        return vim.notify(err_me or "", vim.log.levels.ERROR)
      end
      scratch_file_dir = scratch_file_dir .. vim.g.os_sep
    end
  end
  scratch_file_dir = scratch_file_dir .. paths[p_len]

  utils.scratch(scratch_file_dir, opts.win_config, opts.content, opts.local_keys, opts.cursor)
end

---@param scratch_file_dir string
---@param ft string
---@param opts? Scratch.FiletypeDetail
function M.scratchByType(scratch_file_dir, ft, opts)
  opts = opts or {}
  local abs_path = (opts.generator or utils.get_abs_path)(scratch_file_dir, ft)
  utils.scratch(abs_path, opts.win_config, opts.content, opts.local_keys, opts.cursor)
end

---choose ft by using selector function
---@param scratch_file_dir string
---@param filetypes string[]
---@param selector_filetype fun(filetypes:string[]):string? think about last element like about MANUAL or like u prefers
---@param opts? Scratch.FiletypeDetail
function M.scratchWithSelectorFT(scratch_file_dir, filetypes, selector_filetype, opts)
  coroutine.wrap(function()
    local ft = selector_filetype(filetypes)
    if ft ~= nil and ft ~= "" then
      return M.scratchByType(scratch_file_dir, ft, opts)
    end
    vim.notify("No filetype")
  end)()
end

---choose ft by using selector function
---@param scratch_file_dir string
---@param input_filename fun():string input filename
---@param opts? Scratch.FiletypeDetail
function M.scratchWithInputFN(scratch_file_dir, input_filename, opts)
  coroutine.wrap(function()
    local filename = input_filename()

    if filename ~= nil and filename ~= "" then
      return M.scratchByName(scratch_file_dir, filename, opts)
    end
    vim.notify("No file")
  end)()
end

---simple input name
---@param scratch_file_dir string
---@param opts? Scratch.FiletypeDetail
function M.scratchWithName(scratch_file_dir, opts)
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
      return M.scratchByName(scratch_file_dir, filename, opts)
    end
    vim.notify("No file")
  end)
end

---simple input name
---@param scratch_file_dir string
---@param filetypes string[]
---@param opts? Scratch.FiletypeDetail
function M.scratchWithFt(scratch_file_dir, filetypes, opts)
  vim.ui.select(filetypes, {
    prompt = "Enter the file type: ",
  }, function(ft)
    if ft ~= nil and ft ~= "" then
      return M.scratchByType(scratch_file_dir, ft, opts)
    end
    vim.notify("No file")
  end)
end

return M
