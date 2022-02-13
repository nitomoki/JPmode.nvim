local utils = require'JPmode.utils'
local M = {}

local check_ibus = function()
    vim.cmd('call system("type ibus")')
    return vim.v.shell_error
end

local check_fcitx = function()
    vim.cmd('call system("type fcitx")')
    return vim.v.shell_error
end

local check_swim = function()
    vim.cmd('call system("type swim")')
    return vim.v.shell_error
end


M.isJapaneseMode = false
local winid = nil
local ns = vim.api.nvim_create_namespace("JPmodeWindow")
local hlname = "JPmodeHighlight"
local opening = false
vim.api.nvim_set_hl(ns, hlname, {fg='cyan', bg='green', bold=true})

M.open = function ()
    if opening then return true end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, {"JP"})
    vim.api.nvim_buf_add_highlight(buf, ns, hlname, 0, 0, -1)
    winid = vim.api.nvim_open_win(buf, false, {
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 1,
        height = 1,
        width = 2,
        focusable = false,
        noautocmd = true,
    })
    opening = true
end

M.close = function ()
    if not opening then return true end

    local buf = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_win_close(winid, false)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_delete(buf, {force = true})
    winid = nil
    opening = false
end

M.move = function ()
    if not opening then return true end
    if not winid then return true end

    vim.api.nvim_win_set_config(winid, {
        relative = 'cursor',
        row = 1,
        col = 1,
    })
end

function M.setup()
    local on_command = ""
    local off_command = ""

    if check_ibus() == 0 then
        on_command  = "ibus engine 'xkb:jp::jpn'"
        off_command = "ibus engine 'mozc-jp'"
    elseif check_fcitx() == 0 then
        on_command  = "fcitx-remote -o"
        off_command = "fcitx-remote -c"
    elseif check_swim() == 0 then
        on_command  = "swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"
        off_command = "swim use com.apple.keylayout.ABC"
    else
        return -1
    end


    M.JapaneseInsertOff = function()
        if M.isJapaneseMode  then
            os.execute(off_command)
            M.close()
        end
    end

    M.JapaneseInsertOn = function()
        if M.isJapaneseMode then
            os.execute(on_command)
            M.open()
        end
    end

    function ToggleJapaneseMode(vim_mode)
        M.isJapaneseMode = not(M.isJapaneseMode)
        if (vim_mode == 'i') then
            if M.isJapaneseMode then
                os.execute(on_command)
                M.open()
            else
                os.execute(off_command)
                M.close()
            end
        end
    end

    utils.create_augroup({
        {'InsertLeave',  '*', [[lua require'JPmode'.JapaneseInsertOff()]]},
        {'InsertEnter',  '*', [[lua require'JPmode'.JapaneseInsertOn()]]},
        {'CursorMovedI', '*', [[lua require'JPmode'.move()]]},
    }, 'JapaneseMode')

    vim.keymap.set('i', '<C-]>', function() ToggleJapaneseMode("i") end, {noremap = true})
    vim.keymap.set('n', '<C-]>', function() ToggleJapaneseMode("n") end, {noremap = true})
end

return M
