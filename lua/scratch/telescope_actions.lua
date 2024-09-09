local M = {}

local action_state = require("telescope.actions.state")
local Path = require("plenary").path
local config = require("scratch.config")

-- TODO: register buffer local key
function M.delete_item(prompt_bufnr)
  local _delelte = function(p)
    local flag = false
    while p:exists() do
      local f = os.remove(p.filename)
      if f then
        flag = true
        vim.notify("delete " .. p.filename)
      else
        break
      end
      p = p:parent()
    end
    return flag
  end

  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:delete_selection(function(s)
    local file_name = s[1]
    -- INFO: currently just protect configFilePath from being removed
    if file_name == "configFilePath" then
      vim.notify("[scratch.nvim] configFilePath cannot be removed", vim.log.levels.WARN)
      return false
    end
    local config_data = config.getConfig()
    local scratch_file_dir = config_data.base_dir
    local p = Path:new({ scratch_file_dir, file_name, sep = vim.g.os_sep })
    return _delelte(p)
  end)
end

return M
