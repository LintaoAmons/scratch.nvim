return { ---@type {[string]:vim.api.keyset.win_config?}
  vsplit = {
    split = "left",
    win = 0,
  },
  split = {
    split = "below",
    win = 0,
  },
  edit = nil,
  ["rightbelow vsplit"] = {
    split = "right",
    win = 0,
  },
  popup = {
    relative = "editor", -- Assuming you want the floating window relative to the editor
    row = 2,
    col = 5,
    width = vim.api.nvim_get_option("columns") - 10, -- Get the screen width
    height = vim.api.nvim_get_option("lines") - 5, -- Get the screen height
    style = "minimal",
    border = "single",
    title = "",
  },
}
