-- make sure this file is loaded only once
if vim.g.loaded_scratch == 1 then
  return
end
vim.g.loaded_scratch = 1
vim.g.os_sep = vim.g.os_sep or vim.fn.has("win32") and "\\" or "/"
