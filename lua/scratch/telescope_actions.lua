local M = {}

local config = require("scratch.config")
local utils = require("scratch.utils")
local action_state = require("telescope.actions.state")

-- if telescope loaded, plenary loaded.
local job = require("plenary.job")

local function run_and_get_ret(cmd)
  local ret = true
  job
    :new({
      command = cmd[1],
      args = vim.list_slice(cmd, 2, #cmd),
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          ret = false
          return
        end
      end,
    })
    :sync()
  return ret
end

-- cur: /desktop/
-- paths: a/b/main.go
-- delete /desktop/a/b/main.go -> /desktop/a/b (if b is empty) -> /desktop/a (if a is empty)
local function delete_recursive(i, cur, paths)
  if i == vim.tbl_count(paths) + 1 then
    return
  end

  cur = cur .. utils.Slash() .. paths[i]
  delete_recursive(i + 1, cur, paths)

  local cmd = {}
  if vim.fn.isdirectory(cur) == 0 then -- file
    cmd = { "rm", cur }
  else -- dir
    cmd = { "rmdir", cur }
  end

  local ret = run_and_get_ret(cmd)
  if ret then
    vim.notify("Scratch: delete " .. cur .. " successfully", vim.log.levels.INFO)
  end
end

function M.delete_item(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:delete_selection(function(s)
    local config_data = config.getConfig()
    local scratch_file_dir = config_data.scratch_file_dir
    local paths = vim.fn.split(s[1], utils.Slash())

    delete_recursive(1, scratch_file_dir, paths)

    return true
  end)
end

return M
