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
	scratch_file_dir = vim.env.HOME .. "/scratch.nvim",  -- Where the scratch file will be saved
	filetypes = { "json", "xml" }, -- filetypes to select from
}
```

### Check current Configuration

```lua
require("scratch").checkConfig()
```

## My first nvim plugin

Finally be able to do something

