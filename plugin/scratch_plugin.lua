-- make sure this file is loaded only once
if vim.g.loaded_scratch == 1 then
  return
end
vim.g.loaded_scratch = 1
vim.g.os_sep = vim.g.os_sep or vim.fn.has("win32") and "\\" or "/"

local base_path = vim.fn.stdpath("cache") .. vim.g.os_sep .. "scratch.nvim" .. vim.g.os_sep
---@type Scratch.ActorConfig
vim.g.scratch_config = {
  scratch_file_dir = base_path, -- where your scratch files will be put
  filetypes = { "lua", "js", "py", "sh" }, -- you can simply put filetype here
  win_config = {
    relative = "editor", -- Assuming you want the floating window relative to the editor
    row = 2,
    col = 5,
    width = vim.api.nvim_win_get_width(0) - 10, -- Get the screen width - row * col
    --api_get_option("lines") - 5,
    height = vim.api.nvim_win_get_height(0) - 5, -- Get the screen height - col
    style = "minimal",
    border = "single",
    title = "",
  },
  filetype_details = {},
  localKeys = {},
  manual_text = "MANUAL_INPUT",
}
