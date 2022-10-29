## Create scratch file

Just like IDEA's scratch files. You can create scratch file easily
and use nvim's other goodies.

- with `treesitter`
- with `lsp`
- with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch files

![scratch](https://user-images.githubusercontent.com/95092244/198824640-5137fc7b-0ec5-4634-ac7f-c6042600a63a.gif)

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

### Keymappings

No default keymappings, here's functions you can mapping to.

#### scratch

```lua
vim.keymap.set("n", "<M-C-n>", function() require("scratch").scratch() end)
```

#### checkConfig

This function can print out your current configuration.

I don't think you want to bind this to a shortcut, just use it in command mode to check the config

## My first nvim plugin

Finally be able to do something
