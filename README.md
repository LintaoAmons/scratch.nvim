## Create scratch file

Just like IDEA's scratch files. You can create scratch file easily
and use nvim's other goodies.

- with `treesitter`
- with `lsp`
- with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch files
![scratch](https://user-images.githubusercontent.com/95092244/198858745-b3bc9982-e3e8-44fb-b690-7edca030235e.gif)

## Install

using your favorate plugin manager, for example packer

```lua
use { 
	"LintaoAmons/scratch.nvim",
	tag = "v0.2.0" -- use tag for stability, or without this to have latest fixed and functions
}
```

I will continue add some changes to main branch, so if you meet some issue due to new changes, you can just downgrade to your former version.

## Configuration

### Default Configuration

```lua
require("scratch").setup {
	scratch_file_dir = vim.env.HOME .. "/scratch.nvim",  -- Where the scratch files will be saved
	filetypes = { "json", "xml", "go", "lua", "js", "py" }, -- filetypes to select from
}
```

### Check current Configuration

```lua
:lua require("scratch").checkConfig()
```

### Keymappings | Functions

No default keymappings, here's functions you can mapping to.

#### scratch

This can create a new scratch file in your config's `scratch_file_dir`

```lua
vim.keymap.set("n", "<M-C-n>", function() require("scratch").scratch() end)
```

#### openScratch
> since `v0.2.0`

This can open an old scratch file in your config's `scratch_file_dir`

```lua
vim.keymap.set("n", "<M-C-o>", function() require("scratch").openScratch() end)
```

#### checkConfig

This function can print out your current configuration.

I don't think you want to bind this to a shortcut, just use it in command mode to check the config

## My first nvim plugin

Finally be able to do something
