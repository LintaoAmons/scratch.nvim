local utils = require("scratch.utils")
-- local MANUAL_INPUT_OPTION = "MANUAL_INPUT"

---@class Scratch.Actor
---@field scratch_file_dir string
---@field win_config vim.api.keyset.win_config @see: nvim_open_win() {config}
---@field filetypes string[]
---@field manual_text string
---@field file_picker? "fzflua" | "telescope"
---@field filetype_details Scratch.FiletypeDetails
---@field localKeys Scratch.LocalKeyConfig[]
local M = {}

<<<<<<< HEAD
---@param ft string
---@return string?
function M:get_abs_path(ft)
  local parentDir = self.scratch_file_dir
  local filename
  local require_dir
  if self.filetype_details[ft] then
    -- os.date always string either os.date("*t")
    filename = self.filetype_details[ft].filename or os.date("%y-%m-%d_%H-%M-%S") .. "." .. ft
    local subdir = self.filetype_details[ft].subdir
    if subdir ~= nil then
      parentDir = parentDir .. utils.slash .. subdir
    end
    require_dir = self.filetype_details[ft].requireDir
  else
    filename = os.date("%y-%m-%d_%H-%M-%S") .. "." .. ft
  end
  -- vim.fn.mkdir(parentDir, "p")
  local suc, err_n, err_m = vim.uv.fs_mkdir(parentDir, 777) -- linux rwxrwxrwx
  if not suc then
    return vim.notify(err_n .. ": appear " .. err_m, vim.log.levels.ERROR)
  end
  return utils.genFilepath(filename, parentDir, require_dir)
end
=======
>>>>>>> d47aefd (refactor+feat(input+selector)!)
---@class Scratch.ActionOpts
---@field content? string[] content will be put into the scratch file

---@alias Scratch.Action fun(ft: string, opts?: Scratch.ActionOpts): nil

<<<<<<< HEAD
---@param ft string
---@param config? vim.api.keyset.win_config
function M:create_and_edit_file(ft, config)
  local abs_path = self.scratch_file_dir .. utils.gen_filename(ft)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, abs_path)
  if config == nil then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", self.win_config, config))
  end
end

---@param filename string
function M:scratchByName(filename)
  local scratch_file_dir = self.scratch_file_dir

  local fullpath = scratch_file_dir .. utils.slash .. filename
  self:create_and_edit_file(fullpath)
end

function M:register_local_key()
  local localKeys = self.localKeys
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
---@param opts? Scratch.ActionOpts
function M:write_default_content(ft, opts)
  if opts and opts.content then
    utils.write_lines_to_buffer(opts.content)
  else
    local has_default_content = self.filetype_details[ft]
      and self.filetype_details[ft].content
      and #self.filetype_details[ft].content > 0

    if has_default_content then
      utils.write_lines_to_buffer(self.filetype_details[ft].content)
    end
  end
end

---@param ft string
function M:put_cursor(ft)
  local has_cursor_position = self.filetype_details[ft]
    and self.filetype_details[ft].cursor
    and #self.filetype_details[ft].cursor.location > 0

  if has_cursor_position then
    vim.api.nvim_win_set_cursor(0, self.filetype_details[ft].cursor.location)
    if self.filetype_details[ft].cursor.insert_mode then
      vim.api.nvim_feedkeys("a", "n", true)
    end
  end
end

---@param ft string
---@param opts? Scratch.ActionOpts
function M:scratchByType(ft, opts)
  self:create_and_edit_file(ft, opts)
  self:write_default_content(ft, opts)
  self:put_cursor(ft)
  self:register_local_key()
=======
---@param filename string
---@param win_conf? vim.api.keyset.win_config
---@param content? string[]
---@param local_keys? Scratch.LocalKeyConfig
---@param cursor? Scratch.Cursor
function M:scratchByName(filename, win_conf, content, local_keys, cursor)
  local abs_path = self.base_dir .. filename
  local fto = {}
  for i in filename:gmatch("([^%.]+)") do
    table.insert(fto, i)
  end
  local ft = fto[#fto]
  content = content or self.filetype_details[ft] and self.filetype_details[ft].content
  cursor = cursor or self.filetype_details[ft] and self.filetype_details[ft].cursor
  utils.scratch(abs_path, win_conf or self.win_config, content, local_keys, cursor)
end

---@param ft string
---@param win_conf? vim.api.keyset.win_config
---@param content? string[]
function M:scratchByType(ft, win_conf, content, local_keys, cursor)
  local abs_path = self.base_dir .. utils.gen_filename(ft)
  content = content or self.filetype_details[ft] and self.filetype_details[ft].content
  cursor = cursor or self.filetype_details[ft] and self.filetype_details[ft].cursor
  utils.scratch(abs_path, win_conf or self.win_config, content, local_keys, cursor)
>>>>>>> d47aefd (refactor+feat(input+selector)!)
end

---@return string[]
function M:get_all_filetypes()
  local combined_filetypes = {}
<<<<<<< HEAD
  for _, ft in ipairs(self.filetypes or {}) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end

  for ft, _ in pairs(self.filetype_details or {}) do
    if not vim.tbl_contains(combined_filetypes, ft) then
      table.insert(combined_filetypes, ft)
    end
  end

=======
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

>>>>>>> d47aefd (refactor+feat(input+selector)!)
  table.insert(combined_filetypes, self.manual_text)
  return combined_filetypes
end

<<<<<<< HEAD
---@param func Scratch.Action
---@param opts? Scratch.ActionOpts
function M:select_filetype_then_do(func, opts)
  local filetypes = M:get_all_filetypes()

  vim.ui.select(filetypes, {
    prompt = "Select filetype",
    format_item = function(item)
      return item
    end,
  }, function(choosedFt)
    if choosedFt then
      if choosedFt == self.manual_text then
        vim.ui.input({ prompt = "Input filetype: " }, function(ft)
          func(ft, opts)
        end)
      else
        func(choosedFt, opts)
      end
    end
  end)
end

function M:get_scratch_files()
  local scratch_file_dir = M.scratch_file_dir
  local res = {}
  res = utils.listDirectoryRecursive(scratch_file_dir)
  for i, str in ipairs(res) do
    res[i] = string.sub(str, #scratch_file_dir + 2)
  end
  return res
end

---@param opts? Scratch.ActionOpts
function M:scratch(opts)
  self:select_filetype_then_do(function(ft, opt)
    self:scratchByType(ft, opt)
  end, opts)
end

function M:scratchWithName()
=======
function M.get_scratch_files(base_dir)
  local scratch_file_dir = base_dir
  local res = {}
  res = utils.scandir(scratch_file_dir)
  for i, str in ipairs(res) do
    res[i] = string.sub(str, #scratch_file_dir + 2)
  end
  return res
end

---choose ft by using selector function
---@param selector_filetype fun(filetypes:string[]):string think about last element like about MANUAL or like u prefers
---@param win_conf? vim.api.keyset.win_config
---@param content?  string[]
---@param local_keys? Scratch.LocalKeyConfig
---@param cursor? Scratch.Cursor
function M:scratchWithSelectorFT(selector_filetype, win_conf, content, local_keys, cursor)
  local filetypes = M:get_all_filetypes()
  coroutine.wrap(function()
    local ft = selector_filetype(filetypes)
    self:scratchByType(ft, win_conf, content, local_keys, cursor)
  end)()
end

---choose ft by using selector function
---@param input_filename fun():string input filename
---@param win_conf? vim.api.keyset.win_config
---@param content?  string[]
---@param local_keys? Scratch.LocalKeyConfig
---@param cursor? Scratch.Cursor
function M:scratchWithInputFN(input_filename, win_conf, content, local_keys, cursor)
  coroutine.wrap(function()
    local filename = input_filename()
    self:scratchByName(filename, win_conf, content, local_keys, cursor)
  end)()
end

---simple input name
---@param win_conf? vim.api.keyset.win_config
---@param content?  string[]
---@param local_keys? Scratch.LocalKeyConfig
---@param cursor? Scratch.Cursor
function M:scratchWithName(win_conf, content, local_keys, cursor)
>>>>>>> d47aefd (refactor+feat(input+selector)!)
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
<<<<<<< HEAD
      return self:scratchByName(filename)
=======
      return self:scratchByName(filename, win_conf, content, local_keys, cursor)
>>>>>>> d47aefd (refactor+feat(input+selector)!)
    end
    vim.notify("No file")
  end)
end

<<<<<<< HEAD
function M:open_scratch_fzflua()
  local ok, fzf_lua = pcall(require, "fzf-lua")
  if not ok then
    utils.log_err("Can't find fzf-lua, please check your configuration")
  end

  if vim.fn.executable("rg") ~= 1 then
    utils.log_err("Can't find rg executable, please check your configuration")
  end
  fzf_lua.files({ cmd = "rg --files --sortr modified " .. self.scratch_file_dir })
end

---@param local_keys Scratch.LocalKey[]
function M:open_scratch_telescope(local_keys)
  if not telescope_status then
    vim.notify(
      'ScrachOpen needs telescope.nvim or you can just add `"use_telescope: false"` into your config file ot use native select ui'
    )
    return
  end

  telescope_builtin.find_files({
    cwd = self.scratch_file_dir,
    attach_mappings = function(prompt_bufnr, map)
      map("n", "dd", function()
        require("scratch.telescope_actions").delete_item(prompt_bufnr)
      end)
      -- TODO: user can customise keybinding
      -- for _, key in ipairs(local_keys) do
      --   map(key.modes, key.key, key.cmd)
      -- end
      return true
    end,
  })
end

function M:open_scratch_vim_ui()
  local files = M:get_scratch_files()

  local scratch_file_dir = self.scratch_file_dir

  -- sort the files by their last modified time in descending order
  -- Why?
  table.sort(files, function(a, b)
    return vim.fn.getftime(scratch_file_dir .. utils.slash .. a)
      > vim.fn.getftime(scratch_file_dir .. utils.slash .. b)
  end)

  vim.ui.select(files, {
    prompt = "Select old scratch files",
    format_item = function(item)
      return item
    end,
  }, function(chosenFile)
    if chosenFile then
      M:create_and_edit_file(scratch_file_dir .. utils.slash .. chosenFile)
      M:register_local_key()
    end
  end)
end
---@param opts Scratch.LocalKey[]
function M:scratchOpen(opts)
  if self.file_picker == "telescope" then
    self:open_scratch_telescope(opts)
  elseif self.file_picker == "fzflua" then
    self:open_scratch_fzflua()
  else
    self:open_scratch_vim_ui()
  end
end

function M:fzfScratch()
  if not telescope_status then
    vim.notify("ScrachOpenFzf needs telescope.nvim")
    return
  end

  telescope_builtin.live_grep({
    cwd = self.scratch_file_dir,
  })
end
=======
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
>>>>>>> d47aefd (refactor+feat(input+selector)!)
return M
