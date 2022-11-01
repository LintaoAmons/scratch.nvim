## Create scratch file

Help you to create tmp playground files, which can be found later, 
with one stroke and without worrying about what's the filename and where to put it.

- With other nvim's goodies.
  - with `treesitter` to have syntax highlighting
  - with `lsp` and `cmp` to have auto-cmp, auto-format and other lsp goodies
  - with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch file
  
![scratch](https://user-images.githubusercontent.com/95092244/198858745-b3bc9982-e3e8-44fb-b690-7edca030235e.gif)

## Install

using your favorate plugin manager, for example packer

```lua
use {
	"LintaoAmons/scratch.nvim",
	-- tag = "v0.3.1" -- use tag for stability, or without this to have latest fixed and functions
}
```

I will continue add some changes to main branch, so if you meet some issue due to new changes, you can just downgrade to your former version.

## Configuration

### Default Configuration

```lua
require("scratch").setup {
	scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",  -- Where the scratch files will be saved
	filetypes = { "json", "xml", "go", "lua", "js", "py", "sh" },   -- filetypes to select from
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

#### scratchWithName

> since `v0.3.0`

This can create a new scratch file with user provided filename (But actually you can use `scratch` to create a file then rename the file)

```lua
vim.keymap.set("n", "<M-C-m>", function() require("scratch").scratchWithName() end)
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

## Todo

- [ ] create user command
- [ ] fzf scratch file content and open
- [ ] Template codes when create specific filetype(configurable)

## Change Log

### v0.3.0

- Remove hardcoded path and set default dir to `cache`, thus I think windows can use this, thanks to [#2](https://github.com/LintaoAmons/scratch.nvim/issues/2)
- Add `scratchWithName` function, though I may not use it but I think somebody may find it useful
