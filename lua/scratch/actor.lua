local utils = require("scratch.utils")

---@class Scratch.Actor
---@field scratch_file_dir string
---@field win_config vim.api.keyset.win_config
---@field filetypes string[]
---@field manual_text string
---@field filetype_details Scratch.FiletypeDetails
---@field localKeys Scratch.LocalKeyConfig[]
local M = {}

---@param filename string
---@param opts? Scratch.Opts
function M:scratchByName(filename, opts)
  local paths = {}
  opts = opts or {}

  -- Split filename to dirs
  for sub_path in filename:gmatch("([^" .. vim.g.os_sep .. "]+)") do
    table.insert(paths, sub_path)
  end
  local abs_path = self.scratch_file_dir
  local p_len = #paths

  -- Create all subdir
  for i = 1, p_len - 1 do
    abs_path = abs_path .. paths[i]
    local stat, err_m = vim.uv.fs_stat(abs_path)
    if err_m then
      return vim.notify(err_m, vim.log.levels.ERROR)
    end
    if not stat or stat.type ~= "directory" then
      local suc, err_me = vim.uv.fs_mkdir(abs_path, 666)
      if not suc then
        return vim.notify(err_me or "", vim.log.levels.ERROR)
      end
      abs_path = abs_path .. vim.g.os_sep
    end
  end
  abs_path = abs_path .. paths[p_len]

  local fto = {}
  -- Get filetype
  for i in filename:gmatch("([^%.]+)") do
    table.insert(fto, i)
  end
  local ft = fto[#fto]
  if self.filetype_details[ft] then
    opts.content = opts.content or self.filetype_details[ft].content
    opts.cursor = opts.cursor or self.filetype_details[ft].cursor
  end
  utils.scratch(
    abs_path,
    opts.win_config or self.win_config,
    opts.content,
    opts.local_keys,
    opts.cursor
  )
end

---@param ft string
---@param opts? Scratch.Opts
function M:scratchByType(ft, opts)
  opts = opts or {}
  local generator
  if self.filetype_details[ft] then
    generator = self.filetype_details[ft].generator
    opts.content = opts.content or self.filetype_details[ft].content
    opts.cursor = opts.cursor or self.filetype_details[ft].cursor
  end
  generator = generator or utils.get_abs_path
  local abs_path = generator(self.scratch_file_dir, ft)
  utils.scratch(
    abs_path,
    opts.win_config or self.win_config,
    opts.content,
    opts.local_keys,
    opts.cursor
  )
end

---@return string[]
function M:get_all_filetypes()
  local combined_filetypes = {}
  local cash = {}
  for _, ft in ipairs(self.filetypes or {}) do
    if not cash[ft] then
      table.insert(combined_filetypes, ft)
      cash[ft] = 1
    end
  end
  for ft, _ in pairs(self.filetype_details or {}) do
    if not cash[ft] then
      table.insert(combined_filetypes, ft)
      cash[ft] = 1
    end
  end

  table.insert(combined_filetypes, self.manual_text)
  return combined_filetypes
end

---choose ft by using selector function
---@param selector_filetype fun(filetypes:string[]):string? think about last element like about MANUAL or like u prefers
---@param opts? Scratch.Opts
function M:scratchWithSelectorFT(selector_filetype, opts)
  local filetypes = self:get_all_filetypes()
  coroutine.wrap(function()
    local ft = selector_filetype(filetypes)
    if ft ~= nil and ft ~= "" then
      return self:scratchByType(ft, opts)
    end
    vim.notify("No filetype")
  end)()
end

---choose ft by using selector function
---@param input_filename fun():string input filename
---@param opts? Scratch.Opts
function M:scratchWithInputFN(input_filename, opts)
  coroutine.wrap(function()
    local filename = input_filename()

    if filename ~= nil and filename ~= "" then
      return self:scratchByName(filename, opts)
    end
    vim.notify("No file")
  end)()
end

---simple input name
---@param opts? Scratch.Opts
function M:scratchWithName(opts)
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
      return self:scratchByName(filename, opts)
    end
    vim.notify("No file")
  end)
end

---simple input name
---@param opts? Scratch.Opts
function M:scratchWithFt(opts)
  local fts = self:get_all_filetypes()
  vim.ui.select(fts, {
    prompt = "Enter the file type: ",
  }, function(choice)
    if choice ~= nil and choice ~= "" then
      return self:scratchByType(choice, opts)
    end
    vim.notify("No file")
  end)
end
-- ---@param opts Scratch.LocalKey[]
-- function M:scratchOpen(opts)
-- 	if self.file_picker == "telescope" then
-- 		self:open_scratch_telescope(opts)
-- 	elseif self.file_picker == "fzflua" then
-- 		self:open_scratch_fzflua()
-- 	else
-- 		self:open_scratch_vim_ui()
-- 	end
-- end
return M
