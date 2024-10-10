if vim.g.scratch_load then
  return
end
vim.g.scratch_load = true
vim.g.os_sep = vim.g.os_sep or vim.uv.os_uname().sysname == "Windows_NT" and "\\" or "/"

---@return string[]
local function getSelectedText()
  local sv = vim.fn.getpos("'<")
  local ev = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, sv[2] - 1, ev[2], false)
  local n = #lines
  if n == 0 then
    return {}
  end
  lines[n] = string.sub(lines[n], 1, sv[3])
  lines[1] = string.sub(lines[1], ev[3])
  return lines
end
local actor = require("scratch.actor")
vim.g.scratch_config = setmetatable(require("scratch.config"), actor)

vim.api.nvim_create_user_command("Scratch", function(args)
  if args.range > 0 then
    vim.g.scratch_config:scratchWithFt({ content = getSelectedText() })
  else
    vim.g.scratch_config:scratchWithFt({})
  end
end, { range = true })

vim.api.nvim_create_user_command("ScratchOpen", function()
  vim.g.scratch_config:scratchOpen()
end, {})

vim.api.nvim_create_user_command("ScratchOpenTelescope", function()
  require("scratch.default_finder").findByTelescope(vim.g.scratch_config)
end, {})

vim.api.nvim_create_user_command("ScratchOpenTelescopeGrep", function()
  require("scratch.default_finder").findByTelescopeGrep(vim.g.scratch_config)
end, {})

vim.api.nvim_create_user_command("ScratchWithName", function()
  vim.g.scratch_config:scratchWithName()
end, {})
