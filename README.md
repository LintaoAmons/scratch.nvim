## Create scratch file

Create temporary playground files effortlessly. Find them later without worrying about filenames or locations.

[Scratch Intro](https://github.com/LintaoAmons/scratch.nvim/assets/95092244/c1adff70-c8c5-4594-80e3-18d3e6b24d7a)

## Install & Config

```lua
-- use lazy.nvim
{
  "LintaoAmons/scratch.nvim",
  event = "VeryLazy",
}
```

<details>
<summary>Detailed Configuration</summary>

Check my [neovim config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/scratch.lua) as real life example

```lua
return {
	"LintaoAmons/scratch.nvim",
	config = function()
		require("scratch").setup({
			scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim", -- where your scratch files will be put
			filetypes = { "lua", "js", "sh", "ts" }, -- you can simply put filetype here
			filetype_details = { -- or, you can have more control here
				json = {}, -- empty table is fine
                ["project-name.md"] = {
                    subdir = "project-name" -- group scratch files under specific sub folder
                },
				["yaml"] = {},
				go = {
					requireDir = true, -- true if each scratch file requires a new directory
					filename = "main", -- the filename of the scratch file in the new directory
					content = { "package main", "", "func main() {", "  ", "}" },
					cursor = {
						location = { 4, 2 },
						insert_mode = true,
					},
				},
			},
			window_cmd = "rightbelow vsplit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
			use_telescope = true,
			localKeys = {
				{
					filenameContains = { "sh" },
					LocalKeys = {
						{
							cmd = "<CMD>RunShellCurrentLine<CR>",
							key = "<C-r>",
							modes = { "n", "i", "v" },
						},
					},
				},
			},
		})
	end,
	event = "VeryLazy",
}
```

### Modify config at runtime, no need to restart nvim

To check your current configuration, simply run `lua = vim.g.scratch_config`

And if you want to modify the config, for example add a new filetype. just run the `setup` function with your updated config again.

I normally change the config firstly then selecte the setup function, then run `:'<,'>source` to call the function

Or you can change the `vim.g.scratch_config` global veriable directly

</details>

## Commands & Keymapps

All commands are started with `Scratch`, and no default keymappings.

| Command           | Description                                                                                             |
| ----------------- | ------------------------------------------------------------------------------------------------------- |
| `Scratch`         | Creates a new scratch file in the specified `scratch_file_dir` directory in your configuration.         |
| `ScratchWithName` | Allows the creation of a new scratch file with a user-specified filename, including the file extension. |
| `ScratchOpen`     | Opens an existing scratch file from the `scratch_file_dir`.                                             |
| `ScratchOpenFzf`  | Uses fuzzy finding to search through the contents of scratch files and open a selected file.            |

Keybinding recommandation:

```lua
vim.keymap.set("n", "<M-C-n>", "<cmd>Scratch<cr>")
vim.keymap.set("n", "<M-C-o>", "<cmd>ScratchOpen<cr>")
```

## FIND MORE USER FRIENDLY PLUGINS MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands.nvim](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [plugin-template.nvim](https://github.com/LintaoAmons/plugin-template.nvim)

---

<a href="https://lintao-index.pages.dev/getSupport/">
    <img src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#white" />
</a>
