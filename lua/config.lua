local M = {}

M.default_config = {
	scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
	filetypes = { "json", "xml", "go", "lua", "js", "py", "sh" },
}

M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", M.default_config, user_config or {})
end

return M
