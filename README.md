# JPmode.nvim
A plugin switching Hankaku/Zenkaku for Neovim

## Description

You may want to write Japanese (or some asian languages) with Neovim, but you will definitely find it tedious.
This is because you have to switch Zenkaku for Japanese writing in Insert mode and Hankaku for neovim command in Normal mode.
This plugin allows you to write in Zenkaku in Insert mode and Hankaku in Normal mode, automatically switching Hankaku/Zenkaku.

In JPmode (you can enter it by <C-]> as default), your IME automatically changes to Zenkaku when you enter Insert mode.
Then, you leave Insert mode and your IME becames Hankaku automatically.

## Getting Started

### Required dependencies
You need IME, such as ibus, fcitx and macOS's IME, and know the CLI commands that changes Hankaku/Zenkaku for your IME.

This plugin has configurations for some IME, but you shoud set your switching commands (explained below).

### WARNING!!
This plugin does not plovide any default keymap.

### Installation


Using [packer.nvim](https://github.com/wbthomason/packer.nvim) (for lazy loading)
```lua
use {
    "nitomoki/JPmode.nvim",
    module = "JPmode",
    setup = function()
        vim.keymap.set("i", "<C-]>", require("JPmode").toggle, { noremap = true })
        vim.keymap.set("n", "<C-]>", require("JPmode").toggle, { noremap = true })
    end,
    config = function()
        require("JPmode").setup {
            -- MacOS's config
            on_command = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            off_command = "/usr/local/bin/swim use com.apple.keylayout.ABC",
        }
    end,
}

```

### Usage
Using abave config, you can toggle JPmode to press <C-]>.
In Insert mode, you will see "JP" virtual text on the right of the cursor line.

## configuration
You can configurate the options as the setup function's table.
```lua
require("JPmode").setup {
    -- Zenkaku/Hankaku command.
    -- This example is for MacOS.
    on_command = "/usr/local/bin/swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
    off_command = "/usr/local/bin/swim use com.apple.keylayout.ABC",

    -- highlight of "JP" virtual text.
    highlight = {
        fg = vim.api.nvim_get_hl_by_name("Special", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("CursorLine", true).background,
        bold = true,
    },
}
```
