local utils = require("scratch.utils")

---@class Scratch.Actor
---@field scratch_file_dir string
---@field win_config vim.api.keyset.win_config
---@field filetypes string[]
---@field filetype_details Scratch.FiletypeDetails
---@field manual_text string
---@field localKeys? Scratch.LocalKeyConfig
---@field generator fun(scratch_file_dir:string, ft:string): string, string
---@field scratchOpen fun(self:Scratch.ActorConfig)
local M = {}
M.__index = M

---@param filename string
-- ---@param opts? Scratch.FiletypeDetail
function M:scratchByName(filename)
  local paths = {}

  -- Split filename to dirs
  local last = 1
  local pos = filename:find(vim.g.os_sep)
  while pos do
    table.insert(paths, filename:sub(last, pos))
    last = pos + 1
    pos = filename:find(vim.g.os_sep, last)
  end

  local abs_path = self.scratch_file_dir
  local p_len = #paths
  -- Create all subdir
  for i = 1, p_len do
    abs_path = abs_path .. paths[i]
    local stat, err_m = vim.uv.fs_stat(abs_path)
    if err_m then
      return vim.notify(err_m, vim.log.levels.ERROR)
    end
    if not stat or stat.type ~= "directory" then
      local suc, err_me = vim.uv.fs_mkdir(abs_path, tonumber("0444", 8))
      if not suc then
        return vim.notify(err_me or "", vim.log.levels.ERROR)
      end
    end
  end
  local fname = filename:sub(last)
  abs_path = abs_path .. fname
  pos = fname:reverse():find("%.")
  -- Get filetype
  local ft = fname:sub(1, #fname - pos + 2)
  local opts = {}
  local detail = self.filetype_details[ft]
  if detail then
    opts.content = opts.content or detail.content
    opts.cursor = opts.cursor or detail.cursor
    opts.win_config = opts.win_config or detail.win_config or self.win_config
    opts.local_keys = opts.local_keys or detail.local_keys
  end
  utils.scratch(abs_path, fname, ft, opts)
end

---@param ft string
---@param opts Scratch.FiletypeDetail
function M:scratchByType(ft, opts)
  local detail = self.filetype_details[ft]
  if detail then
    opts.content = opts.content or detail.content
    opts.cursor = opts.cursor or detail.cursor
    opts.win_config = opts.win_config or detail.win_config or self.win_config
    opts.local_keys = opts.local_keys or detail.local_keys
  end
  local abs_path, fname = (detail.generator or self.generator)(self.scratch_file_dir, ft)
  utils.scratch(abs_path, fname, ft, opts)
end

---@return string[]
-- function M:get_all_filetypes()
--   local combined_filetypes = {}
--   local cash = {}
--   for _, ft in ipairs(self.filetypes or {}) do
--     if not cash[ft] then
--       table.insert(combined_filetypes, ft)
--       cash[ft] = 1
--     end
--   end
--   for ft, _ in pairs(self.filetype_details or {}) do
--     if not cash[ft] then
--       table.insert(combined_filetypes, ft)
--       cash[ft] = 1
--     end
--   end
--   table.insert(combined_filetypes, self.manual_text)
--   return combined_filetypes
-- end

---choose ft by using selector function
---@param selector_filetype fun(filetypes:string[]):string? think about last element like about MANUAL or like u prefers
function M:scratchWithSelectorFT(selector_filetype)
  coroutine.wrap(function()
    local ft = selector_filetype(self.filetypes)
    if ft ~= nil and ft ~= "" then
      return self:scratchByType(ft)
    end
    vim.notify("No filetype")
  end)()
end

---choose ft by using selector function
---@param input_filename fun():string input filename
function M:scratchWithInputFN(input_filename)
  coroutine.wrap(function()
    local filename = input_filename()
    if filename ~= nil and filename ~= "" then
      return self:scratchByName(filename)
    end
    vim.notify("No file")
  end)()
end

---simple input name
function M:scratchWithName()
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
      return self:scratchByName(filename)
    end
    vim.notify("No file")
  end)
end

---simple input name
---@param opts Scratch.FiletypeDetail
function M:scratchWithFt(opts)
  -- local fts = self:get_all_filetypes()
  vim.ui.select(self.filetypes, {
    prompt = "Enter the file type: ",
  }, function(choice)
    if choice ~= nil and choice ~= "" then
      return self:scratchByType(choice, opts)
    end
    vim.notify("No file")
  end)
end

-- function M:scratchOpen()
-- 	self
-- end
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
