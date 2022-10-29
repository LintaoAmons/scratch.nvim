## Create scratch file

Just like IDEA's scratch files. You can create scratch file easily 
and use nvim's other goodies.

- with `treesitter`
- with `lsp`
- with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch files

## Configuration

### Default Configuration

```lua
require("scratch").setup {
	scratch_file_dir = vim.env.HOME .. "/scratch.nvim",  -- Where the scratch files will be saved
	filetypes = { "json", "xml" }, -- filetypes to select from
}
```

### Check current Configuration

```lua
require("scratch").checkConfig()
```

### Keymappings

No default keymappings, here's functions you can mapping to.

#### scratch

```lua
vim.keymap.set("n", "<M-C-n>", function() require("scratch").scratch() end)
```

#### checkConfig

This function can print out your current configuration.

```lua
vim.keymap.set("n", "<M-C-n>", function() require("scratch").checkConfig() end)
```

## My first nvim plugin

Finally be able to do something

