local M = {}

local check_command = function(arg)
    local cmd = ("call system('type %s')"):format(arg)
    vim.cmd(cmd)
    return vim.v.shell_error
end

local isJapaneseMode = false
local winid = nil
local ns = vim.api.nvim_create_namespace "JPmodeWindow"
local hlname = "JPmodeHighlight"
local opening = false
vim.api.nvim_set_hl(ns, hlname, { fg = "cyan", bg = "green", bold = true })

local JPwin_open = function()
    if opening then
        return true
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "JP" })
    vim.api.nvim_buf_add_highlight(buf, ns, hlname, 0, 0, -1)
    winid = vim.api.nvim_open_win(buf, false, {
        style = "minimal",
        relative = "cursor",
        row = 1,
        col = 1,
        height = 1,
        width = 2,
        focusable = false,
        noautocmd = true,
    })
    opening = true
end

local JPwin_close = function()
    if not opening then
        return true
    end

    local buf = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_win_close(winid, false)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_delete(buf, { force = true })
    winid = nil
    opening = false
end

local JPwin_move = function()
    if not opening then
        return true
    end
    if not winid then
        return true
    end

    vim.api.nvim_win_set_config(winid, {
        relative = "cursor",
        row = 1,
        col = 1,
    })
end

function M.setup(opt)
    if not opt then
        M.on_command = opt.on_command or nil
        M.off_command = opt.off_command or nil
    end

    if not M.on_command and not M.off_command then
        if check_command "ibus" == 0 then
            M.on_command = "ibus engine 'mozc-jp'"
            M.off_command = "ibus engine 'xkb:jp::jpn'"
        elseif check_command "fcitx" == 0 then
            M.on_command = "fcitx-remote -o"
            M.off_command = "fcitx-remote -c"
        elseif check_command "swim" == 0 then
            M.on_command = "swim use com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"
            M.off_command = "swim use com.apple.keylayout.ABC"
        else
            print "JPmode: error! cannot be set Japanese IME command. Please set options explicity."
            return -1
        end
    end

    M.JapaneseInsertOff = function()
        if isJapaneseMode then
            os.execute(M.off_command)
            JPwin_close()
        end
    end

    M.JapaneseInsertOn = function()
        if isJapaneseMode then
            os.execute(M.on_command)
            JPwin_open()
        end
    end

    local ToggleJapaneseMode = function()
        isJapaneseMode = not isJapaneseMode

        local mode = vim.fn.mode()
        if mode == "i" then
            if isJapaneseMode then
                os.execute(M.on_command)
                JPwin_open()
            else
                os.execute(M.off_command)
                JPwin_close()
            end
        end
        if mode == "c" then
            if isJapaneseMode then
                os.execute(M.on_command)
            else
                os.execute(M.off_command)
            end
        end
    end

    local OffJapaneseMode = function()
        if isJapaneseMode then
            local mode = vim.fn.mode()
            if mode == "i" then
                os.execute(M.off_command)
                JPwin_close()
            elseif mode == "n" or mode == "c" then
                os.execute(M.off_command)
            end
        end
        isJapaneseMode = false
    end

    local id_jpmode = vim.api.nvim_create_augroup("JapaneseMode", {})
    vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
        group = id_jpmode,
        pattern = "*",
        callback = M.JapaneseInsertOff,
    })
    vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
        group = id_jpmode,
        pattern = "*",
        callback = M.JapaneseInsertOn,
    })
    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
        group = id_jpmode,
        pattern = "*",
        callback = JPwin_move,
    })

    vim.keymap.set("i", "<C-]>", ToggleJapaneseMode, { noremap = true })
    vim.keymap.set("n", "<C-]>", OffJapaneseMode, { noremap = true })
    vim.keymap.set("c", "<C-]>", ToggleJapaneseMode, { noremap = true })
end

return M
