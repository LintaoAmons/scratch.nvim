## Create scratch file

Help you to create tmp playground files, which can be found later,
with one stroke and without worrying about what the filename should be and where to put it.

- With other nvim's goodies.
  - with `treesitter` to have syntax highlighting
  - with `lsp` and `cmp` to have auto-cmp, auto-format and other lsp goodies
  - with `michaelb/sniprun` or `metakirby5/codi.vim` to run scratch file

![scratch](https://user-images.githubusercontent.com/95092244/198858745-b3bc9982-e3e8-44fb-b690-7edca030235e.gif)

## Install

using your favorate plugin manager, for example [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
  {
    "LintaoAmons/scratch.nvim",
    event = 'VimEnter',
    -- tag = "v0.7.1" -- use tag for stability, or without this to have latest fixed and functions
  }

```

I will continue add some changes to main branch, so if you meet some issue due to new changes, you can just downgrade to your former version.

- Here are major versions your can revert to:
  - `v0.8.0`: Allow group type of file in specific subdir
  - `v0.7.1`: config to jsonfile
  - `v0.5.0`: add subdirectory
  - Find other tags at https://github.com/LintaoAmons/scratch.nvim/tags

## Configuration

Just install and use the commands it provides.

You can search commands with `Scratch` prefix by telescope or fzflua

Here's default config after you inited the plugin

```jsonc
{
  "filetypes": ["xml", "go", "lua", "js", "py", "sh"], // you can simply put filetype here
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
  }
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

## Todo

- [ ] scratch a file based on visual selection
- [x] group type of file into it's own specific subdir
- [x] take effect right after user save the configuration.
- [x] move config.json to nvim's configuration folder
- [x] register the command automaticlly
- [x] Template codes when create specific filetype(configurable)
- [x] fzf scratch file content and open
- [x] create user command
