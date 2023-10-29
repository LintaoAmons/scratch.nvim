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

using your favorate plugin manager, for example [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "LintaoAmons/scratch.nvim",
  event = 'VimEnter',
}
```


## Configuration

No need to config at the very begining, just install and explore.

You can search commands with `Scratch` prefix by telescope or fzflua

You can use `ScratchEditConfig` to edit the config once some new type popup your mind and the config will take effect immediately

Here's default config after you inited the plugin

NOTE: you can't have comment in your config, since only plain json supported right now

```jsonc
{
  "filetypes": ["xml", "go", "lua", "js", "py", "sh"], // you can simply put filetype here
  "window_cmd": "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'. Can use rightbelow or topleft etc. as modifier
  "scratch_file_dir": "/you_home_path/.cache/nvim/scratch.nvim",
  "filetype_details": {
    "go": {
      // or, you can have more control here
      "filename": "main", // the filename of the scratch file in the new directory
      "cursor": {
        "location": [4, 2], // default location of cursor in the scratch file
        "insert_mode": true // default mode
      },
      "requireDir": true, // true, if each scratch file requires a new directory
      "content": ["package main", "", "func main() {", "  ", "}"] // default content in the scratch file
    },
    "yaml": {}, // for same filetype. you can have different postfix
    "k8s.yaml": {
      "subdir": "learn-k8s" // and put this type into a specific subdir
    },
    "json": {}, // empty object is fine
    "gp.md": {
      // create `gp.nvim` chat file
      "cursor": {
        "location": [12, 2],
        "insert_mode": true
      },
      "content": [
        "# topic: ?",
        "",
        "- model: {\"top_p\":1,\"temperature\":0.7,\"model\":\"gpt-3.5-turbo-16k\"}",
        "- file: placeholder",
        "- role: You are a general AI assistant.",
        "",
        "Write your queries after 🗨:. Run :GpChatRespond to generate response.",
        "",
        "---",
        "",
        "🗨:",
        ""
      ]
    }
  },
  "localKeys": [
    // local keymapping for specific type of file
    {
      "filenameContains": ["gp"],
      "LocalKeys": [
        {
          "cmd": "<CMD>GpChatRespond<CR>",
          "key": "<C-k>k",
          "modes": ["n", "i", "v"]
        }
      ]
    }
  ]
}
```

<details>
<summary>Click to know more about config</summary>

The way to config this plugin is a little difference(simpler) with other nvim plugin.
You can use `ScratchEditConfig` to edit the config and the config will take effect immediately

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

**Note**: Don't need require restart nvim after change the config.

![show](https://github.com/LintaoAmons/scratch.nvim/assets/95092244/8e3fe968-91a5-4e86-a34e-84f9274b3355)

</details>

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

### ScratchPad

A file where you can continuously record information.


### Functions

functions can be required from scratch, check `./lua/scratch/init.lua` to get the functions you can use

## Jump to scratch file from terminal

```sh
nvim -c 'lua require("scratch").scratchByType("md")'
```

> NOTE: you can't lazyload the plugin if you want make the `scratch` plugin accessible at the init of nvim

## Todo

- [ ] refactor: init_intercepter to the checkInit method to allow range commands like scratchPad
- [x] local shortcuts.
- [ ] scratch a file based on visual selection
- [x] group type of file into it's own specific subdir
- [x] take effect right after user save the configuration.
- [x] move config.json to nvim's configuration folder
- [x] register the command automaticlly
- [x] Template codes when create specific filetype(configurable)
- [x] fzf scratch file content and open
- [x] create user command
