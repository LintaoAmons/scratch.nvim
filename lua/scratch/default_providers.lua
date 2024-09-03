local utils = require("scratch.utils")
local M = {}

--- NOTE: if u want using async choicer inside your own functions with non ( :h api-fast )
--- wrap these choicer into vim.schedule_wrap
--- dummy async
--- @example
--- function M.dummy(args)
---		local co = coroutine.running()
---		local choicer = function()
---			-- instead return use coroutine.resume(co, your_return)
---		end
---		return coroutine.yield()
--- end

function M.vim_ui_selector(filetypes)
  local co = coroutine.running()
  vim.ui.select(filetypes, {
    prompt = "Select filetype",
    format_item = function(item)
      return item
    end,
  }, function(choosedFt)
    if choosedFt then
      if choosedFt == filetypes[#filetypes] then
        vim.ui.input({ prompt = "Input filetype: " }, function(ft)
          coroutine.resume(co, ft)
        end)
      else
        coroutine.resume(co, choosedFt)
      end
    end
  end)
  return coroutine.yield()
end
function M.vim_ui_input()
  local co = coroutine.running()
  vim.ui.input({
    prompt = "Enter the file name: ",
  }, function(filename)
    if filename ~= nil and filename ~= "" then
      coroutine.resume(co, filename)
    else
      vim.notify("No file")
    end
  end)
  return coroutine.yield()
end
return M
