> Breaking Change!: use setup function instead of json config.
> If you meet any issue, you can use tag to downgrade to previous version, like `v0.13.2`


## Create scratch file

Create temporary playground files
effortlessly. Find them later without
worrying about filenames or locations

- With other nvim's goodies.
  - with `treesitter` to have syntax highlighting
  - with `lsp` and `cmp` to have auto-cmp, auto-format and other lsp goodies
  - with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch file

[Scratch Intro](https://github.com/LintaoAmons/scratch.nvim/assets/95092244/c1adff70-c8c5-4594-80e3-18d3e6b24d7a)


## Install

use your favorite plugin manager, for example [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "LintaoAmons/scratch.nvim",
  tag = "v1.0.0",
  event = "VeryLazy",
}
```

## Configuration

No configuration is required; it can be used out of the box. Simply install it and explore the commands that start with 'Scratch'.

<details>
<summary>Detailed Configuration</summary>
  
You can use both `Lua setup function` and `Json config` to fit your needs.

`Lua setup function` and `Json config` will eventually be merged together.

  
You can use `ScratchEditConfig` to edit the JSON configuration whenever a new type comes to mind, and the changes will take effect immediately.

Following is a detailed `Lua setup configuration`

```lua
return {
	"LintaoAmons/scratch.nvim",
	config = function()
        ---@type Scratch.SetupConfig
        local cfg = {
			json_config_path = vim.fn.stdpath("config") .. "/scratch.json",
			scratch_config = {
				scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim", -- where your scratch files will be put
				filetypes = { "lua", "sh" }, -- you can simply put filetype here
				window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
				use_telescope = true,
				filetype_details = { -- or, you can have more control here
					json = {}, -- empty table is fine
					["k8s.yaml"] = { -- you can have different postfix
						subdir = "learn-k8s", -- and all file with this postfix will be put into this specific sub-directory
					},
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
				localKeys = { -- you can have local shortcuts when a scratch file created
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
			},
		}

		require("scratch").setup(cfg)
	end,
	event = "VeryLazy",
}
```

> NOTE: if there're options both setted in `Lua setup function` and `Json config`, then the `Lua setup function` have higher priority and will sync to Json config once the setup function been called again (like restart neovim).

</details>

## Commands | Keymappings | Functions

All commands are started with `Scratch`, and no default Keymappings. Here is one example to add your keybinding to the commands.

```lua
vim.keymap.set("n", "<M-C-n>", "<cmd>Scratch<cr>")
vim.keymap.set("n", "<M-C-o>", "<cmd>ScratchOpen<cr>")
```

| Command            | Description                                                                                                           |
|--------------------|-----------------------------------------------------------------------------------------------------------------------|
| `Scratch`          | Creates a new scratch file in the specified `scratch_file_dir` directory in your configuration.                       |
| `ScratchWithName`  | Allows the creation of a new scratch file with a user-specified filename, including the file extension.               |
| `ScratchOpen`      | Opens an existing scratch file from the `scratch_file_dir`.                                                           |
| `ScratchOpenFzf`   | Uses fuzzy finding to search through the contents of scratch files and open a selected file.                          |
| `ScratchEditConfig` | Opens the configuration file for editing, with changes taking effect without needing to restart Neovim.              |

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

You can contact with me by drop me an email or [telegram](https://t.me/+ssgpiHyY9580ZWFl)

## FIND MORE USER FRIENDLY PLUGINS MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands.nvim](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [plugin-template.nvim](https://github.com/LintaoAmons/plugin-template.nvim)
