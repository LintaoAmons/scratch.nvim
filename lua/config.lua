local M = {
	scratch_file_dir = vim.env.HOME .. "/scratch.nvim",
	filetypes = { "json", "xml" },
}

vim.ui.select(M.filetypes, {
	prompt = "Select filetype",
	format_item = function(item)
		return item
	end,
}, function(choice)
	vim.notify(choice)
end)

return M
