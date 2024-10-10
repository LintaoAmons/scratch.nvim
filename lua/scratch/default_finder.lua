local M = {}
--@param sorter? fun(file_a:string, file_b:string):boolean @see: table.sort
--@param win_config? vim.api.keyset.win_config
--@param local_keys? Scratch.LocalKeyConfig

---@param self Scratch.Actor
function M.native(self)
  local utils = require("scratch.utils")
  local scratch_file_dir = self.scratch_file_dir
  local abs_filenames = utils.scandir(scratch_file_dir)
  -- if opts and opts.sorter then
  --   table.sort(abs_filenames, opts.sorter)
  -- end
  -- sort the files by their last modified time in descending order
  -- Why?
  table.sort(abs_filenames, function(a, b)
    return vim.fn.getftime(scratch_file_dir .. vim.g.os_sep .. a)
      > vim.fn.getftime(scratch_file_dir .. vim.g.os_sep .. b)
  end)
  vim.ui.select(abs_filenames, {
    prompt = "Select old scratch files",
    format_item = function(item)
      return item
    end,
  }, function(chosenFile)
    if chosenFile then
      utils.open_(chosenFile, self.win_config)
      -- if opts and opts.local_keys then
      --   utils.register_local_key(opts.local_keys)
      -- end
    end
  end)
end

---@param self Scratch.Actor
M["fzflua"] = function(self)
  local ok, fzf_lua = pcall(require, "fzf-lua")
  if not ok then
    return vim.notify(
      "Can't find fzf-lua, please check your configuration",
      vim.log.levels.ERROR,
      { title = "scratch.nvim" }
    )
  end

  if vim.fn.executable("rg") ~= 1 then
    return vim.notify(
      "Can't find fzf-lua, please check your configuration",
      vim.log.levels.ERROR,
      { title = "scratch.nvim" }
    )
  end
  fzf_lua.files({ cmd = "rg --files --sortr modified " .. self.scratch_file_dir })
end

---@param self Scratch.ActorConfig
function M.telescope(self)
  local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")
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
      if self.localKeys then
        local lkeys = self.localKeys.LocalKeys
        for i = 1, #lkeys do
          map(lkeys[i].mode, lkeys[i].lhs, lkeys[i].rhs)
        end
      end
      return true
    end,
  })
end

---@param self Scratch.ActorConfig
function M.findByTelescopeGrep(self)
  local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")
  if not telescope_status then
    return vim.notify("ScrachOpenFzf needs telescope.nvim")
  end
  telescope_builtin.live_grep({
    cwd = self.scratch_file_dir,
  })
end

return M
