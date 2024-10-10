local M = {}

---@param user_config Scratch.ActorConfig
---@return Scratch.Actor
function M.setup(user_config)
  user_config = user_config or {}
  local tmp_win = vim.g.scratch_config.win_config
  local tmp_fi = vim.g.scratch_config.scratchOpen
  vim.g.scratch_config = vim.tbl_deep_extend("force", vim.g.scratch_config, user_config)

  if type(user_config.win_cmd) == "table" then
    vim.g.scratch_config.win_config = user_config.win_cmd
  elseif type(user_config.win_cmd) == "string" then
    vim.g.scratch_config.win_config = require("scratch.default_win")[user_config.win_cmd]
  else
    vim.g.scratch_config.win_config = tmp_win
  end

  if type(user_config.file_picker) == "function" then
    vim.g.scratch_config.scratchOpen = user_config.file_picker
  elseif type(user_config.file_picker) == "string" then
    vim.g.scratch_config.scratchOpen = require("scratch.default_finder")[user_config.file_picker]
  else
    vim.g.scratch_config.scratchOpen = tmp_fi
  end

  if
    vim.g.scratch_config.scratch_file_dir
    and not vim.uv.fs_stat(vim.g.scratch_config.scratch_file_dir).type == "directory"
  then
    vim.uv.fs_mkdir(vim.g.scratch_config.scratch_file_dir, 666)
  end
  return vim.g.scratch_config
end

return M
