> [!WARNING]
> There's a new patch comming, which has a thorough overhaul of the config module and will cause breaking changes.
> 
> Please use tag to pin the version if you don't want to modify your current configuration
> 
> If you want to try it now, you can switch to `config-refacor` branch or pr `37`

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
  tag = "v0.13.2",
  event = "VeryLazy",
}
```


## Configuration

No need to config at the very begining, just install and explore the commands start with `Scratch`.

<details>
<summary>Click to know more about config</summary>
  
The way to config this plugin is a little difference(simpler) with other nvim plugin.
  
You can use `ScratchEditConfig` to edit the config once some new type popup your mind and the config will take effect immediately

Here's default config after you inited the plugin

NOTE: you can't have comment in your config, since only plain json supported right now

```jsonc
{
  "filetypes": ["xml", "go", "lua", "js", "py", "sh"], // you can simply put filetype here
  "window_cmd": "edit", // 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'. Can use rightbelow or topleft etc. as modifier
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

| Command            | Description                                                                                                           |
|--------------------|-----------------------------------------------------------------------------------------------------------------------|
| `Scratch`          | Creates a new scratch file in the specified `scratch_file_dir` directory in your configuration.                       |
| `ScratchWithName`  | Allows the creation of a new scratch file with a user-specified filename, including the file extension.               |
| `ScratchOpen`      | Opens an existing scratch file from the `scratch_file_dir`.                                                           |
| `ScratchOpenFzf`   | Uses fuzzy finding to search through the contents of scratch files and open a selected file.                          |
| `ScratchCheckConfig` | Prints the current configuration to confirm that custom settings are active.                                         |
| `ScratchEditConfig` | Opens the configuration file for editing, with changes taking effect without needing to restart Neovim.              |
| `ScratchPad`       | A specific file designed for continuous information recording, likely acting as an ongoing note-taking or log file.   |

### Functions

functions can be required from scratch, check `./lua/scratch/init.lua` to get the functions you can use

## Jump to scratch file from terminal

```sh
nvim -c 'lua require("scratch").scratchByType("md")'
```

> NOTE: you can't lazyload the plugin if you want make the `scratch` plugin accessible at the init of nvim

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

You can contact with me by drop me an email or [telegram](https://t.me/+ssgpiHyY9580ZWFl)

## FIND MORE USER FRIENDLY PLUGINS MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands.nvim](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [plugin-template.nvim](https://github.com/LintaoAmons/plugin-template.nvim)
