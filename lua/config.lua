local M = {}

local default_config = {
	scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",
	filetypes = { "json", "xml", "go", "lua", "js", "py", "sh" },
}

M.config = default_config

M.setup = function(user_config)
	print("Called setup")
	print(vim.inspect(user_config))
	M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
	print(vim.inspect(M.config))
end

return M
