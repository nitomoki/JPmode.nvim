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
**This plugin does not plovide any default keymap.**

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
This is an example for MacOS(swim) and WSL2(zenhan.exe).
```lua
local opt = {
    enable = false,
    jp = nil,
    en = nil,
}
if vim.fn.has "mac" == 1 then
    local swim = "/usr/local/bin/swim"
    if vim.fn.executable(swim) ~= 1 then
        opt.enable = true
        opt.jp = {
            cmd = swim,
            args = { "use", "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese" },
        }
        opt.en = {
            cmd = swim,
            args = { "use", "com.apple.keylayout.ABC" },
        }
    end
end
if vim.fn.has "wsl" == 1 then
    local zenhan = vim.g.WSL_HOME .. "scoop/apps/zenhan/current/zenhan.exe"
    if vim.fn.executable(zenhan) == 1 then
        opt.enable = true
        opt.jp = {
            cmd = zenhan,
            args = { "1" },
        }
        opt.en = {
            cmd = zenhan,
            args = { "0" },
        }
    end
end

return {
    "nitomoki/JPmode.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    lazy = true,
    init = function()
        if not opt.enable then
            return
        end
        local keymap = nil
        if vim.fn.has "wsl" == 1 then
            keymap = "<C-Space>"
        end
        if vim.fn.has "mac" == 1 then
            keymap = "<C-M-Space>"
        end
        vim.keymap.set({ "i", "c" }, keymap, require("JPmode").toggle, { silent = true, noremap = true })
        vim.keymap.set("n", keymap, require("JPmode").off, { silent = true, noremap = true })
    end,
    config = function()
        if not opt.enable then
            return
        end
        require("JPmode").setup(opt)
        vim.api.nvim_create_autocmd("User", { pattern = "TelescopeKeymap", callback = require("JPmode").off })
    end,
}
```

### Usage
Using abave config, you can toggle JPmode to press <C-Space>.
In Insert mode, you will see "JP" virtual text on the right of the cursor line.

## configuration
You can configurate the options as the setup function's table.
```lua
require("JPmode").setup {
    -- Zenkaku/Hankaku command.
    -- This example is for MacOS.
    jp = {
        cmd = "/usr/local/bin/swim",
        args = { "use", "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese" },
    }
    en = {
        cmd = "/usr/local/bin/swim",
        args = {"use", "com.apple.keylayout.ABC" },
    }

    -- highlight of "JP" virtual text.
    highlight = {
        fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg,
        bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg,
        bold = true,
    },
}
```
