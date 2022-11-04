local jp_vtxt = require "JPmode.jp_vtxt"
local jp_maps = require "JPmode.jp_maps"
local M = {}

local check_command = function(arg)
    local cmd = ("call system('type %s')"):format(arg)
    vim.cmd(cmd)
    return vim.v.shell_error
end

local isJapaneseMode = false
local id_jpmode = nil
local aucmd = nil

local IME = {
    jp = nil,
    en = nil,
}

local jp_insertion_end = function()
    os.execute(IME.en)
    jp_vtxt.close()
end

local jp_insertion_start = function()
    os.execute(IME.jp)
    jp_vtxt.open()
end

local jp_mode_on = function()
    if vim.fn.mode() == "i" then
        jp_insertion_start()
    end

    if isJapaneseMode then
        return
    end

    if id_jpmode and not aucmd then
        aucmd = {}
        aucmd.InsL = vim.api.nvim_create_autocmd("InsertLeave", {
            group = id_jpmode,
            pattern = "*",
            callback = jp_insertion_end,
        })
        aucmd.InsE = vim.api.nvim_create_autocmd("InsertEnter", {
            group = id_jpmode,
            pattern = "*",
            callback = jp_insertion_start,
        })
        aucmd.CurM = vim.api.nvim_create_autocmd("CursorMovedI", {
            group = id_jpmode,
            pattern = "*",
            callback = jp_vtxt.move,
        })
        aucmd.TeleFP = vim.api.nvim_create_autocmd("User TelescopePreviewerLoaded", {
            group = id_jpmode,
            pattern = "*",
            callback = jp_insertion_end,
        })
    end

    jp_maps.set()

    isJapaneseMode = true
end

local jp_mode_off = function()
    if vim.fn.mode() == "i" then
        jp_insertion_end()
    end

    if not isJapaneseMode then
        return
    end

    if aucmd then
        for _, id in pairs(aucmd) do
            vim.api.nvim_del_autocmd(id)
        end
        aucmd = nil
    end

    jp_maps.del()

    isJapaneseMode = false
end

local jp_mode_toggle = function()
    if isJapaneseMode then
        -- On -> Off
        jp_mode_off()
    else
        -- Off -> On
        jp_mode_on()
    end
end

M.setup = function(opt)
    isJapaneseMode = false

    if opt then
        IME.jp = opt.on_command or nil
        IME.en = opt.off_command or nil
        jp_vtxt.setup(opt)
    end

    if not IME.jp and not IME.en then
        if check_command "ibus" == 0 then
            IME.jp = "ibus engine 'mozc-jp'"
            IME.en = "ibus engine 'xkb:jp::jpn'"
        elseif check_command "fcitx" == 0 then
            IME.jp = "fcitx-remote -o"
            IME.en = "fcitx-remote -c"
        elseif check_command "swim" == 0 then
            IME.jp = "swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"
            IME.en = "swim use com.apple.keylayout.ABC"
        else
            print "JPmode: error! cannot be set Japanese IME command. Please set options explicity."
            return -1
        end
    end

    id_jpmode = vim.api.nvim_create_augroup("JapaneseMode", {})

    if opt.keymap then
        if opt.keymap.i.toggle then
            vim.keymap.set("i", opt.keymap.i.toggle, jp_mode_toggle, { noremap = true })
        end
        if opt.keymap.i.on then
            vim.keymap.set("i", opt.keymap.i.on, jp_mode_on, { noremap = true })
        end
        if opt.keymap.i.off then
            vim.keymap.set("i", opt.keymap.i.off, jp_mode_off, { noremap = true })
        end
        if opt.keymap.n.toggle then
            vim.keymap.set("n", opt.keymap.n.toggle, jp_mode_toggle, { noremap = true })
        end
        if opt.keymap.n.on then
            vim.keymap.set("n", opt.keymap.n.on, jp_mode_on, { noremap = true })
        end
        if opt.keymap.n.off then
            vim.keymap.set("n", opt.keymap.n.off, jp_mode_off, { noremap = true })
        end
    else
        vim.keymap.set("i", "<C-]>", jp_mode_toggle, { noremap = true })
        vim.keymap.set("n", "<C-]>", jp_mode_toggle, { noremap = true })
    end
end

return M
