**Breaking change**: the way to config the plugin have change to json, see the Configuration section for more information

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
	-- tag = "v0.7.0" -- use tag for stability, or without this to have latest fixed and functions
}
```

I will continue add some changes to main branch, so if you meet some issue due to new changes, you can just downgrade to your former version.

- Here are major versions your can revert to:
    - `v0.7.0`: config to jsonfile
    - `v0.5.0`: add subdirectory
    - `v0.4.0`: Add ScratchOpenFzf
    - Find other tags at https://github.com/LintaoAmons/scratch.nvim/tags

## Configuration

### Init Configuration

- This is triggered automaticlly at the first time you try to use Scrach's commands, and can be manually called to change the configuration file path, and this allows you:
  - Put your configuration anywhere you want and can be tracked along with your other configuration with git
  - Have multiple configuration, and switch the configuration by change the configuration filepath with this command

```lua
:ScratchInitConfig
```

### Check current Configuration

```lua
:ScratchCheckConfig
```

### Edit Configuration

```lua
:ScratchEditConfig
```

**Note**: Require restart nvim after change the config.

![scratch_config](https://user-images.githubusercontent.com/95092244/227540633-d256fcda-1c80-4ea0-b416-bde872d52571.gif)

## Commands | Keymappings | Functions

No default keymappings, here's functions you can mapping to.

All commands are started with `Scratch`, here is one example to add your keybinding to the commands.

```lua
vim.keymap.set("n", "<M-C-n>", "<cmd>Scratch<cr>")
vim.keymap.set("n", "<M-C-o>", "<cmd>ScratchOpen<cr>")
```

Before `v0.6.2` you may need to map to the lua function. Checkout the specific git tag to check the README to the version you want. Here is one example to mapping lua function.

```lua
vim.keymap.set("n", "<M-C-n>", function() require("scratch").scratch() end)
vim.keymap.set("n", "<M-C-o>", function() require("scratch").openScratch() end)
```

### Scratch

This can create a new scratch file in your config's `scratch_file_dir`

### ScratchWithName

This can create a new scratch file with user provided filename (respect the file extension you provided along with the filename)

### ScratchOpen

This can open an old scratch file in your config's `scratch_file_dir`

### ScratchOpenFzf

Fuzzy find the content of your scratch files and open

### ScratchCheckConfig

This function can print out your current configuration. Let you rest assure that your custom configuration is taken effect.

### ScratchEditConfig

Open the configuration file and you can edit it to fit your needs. Require restart nvim to take effects.

## Todo

- [ ] take effect right after user save the configuration.
- [ ] move config.json to nvim's configuration folder
- [x] register the command automaticlly
- [x] Template codes when create specific filetype(configurable)
- [x] fzf scratch file content and open
- [x] create user command
