local M = {}

local check_command = function(arg)
    local cmd = ("call system('type %s')"):format(arg)
    vim.cmd(cmd)
    return vim.v.shell_error
end

M.isJapaneseMode = false
local vtxtid = nil
local ns = vim.api.nvim_create_namespace "JPmodeWindow"
local hlname = "JPmodeHighlight"
local virt_text = { { " JP", "VirtualTextInfo" } }
vim.api.nvim_set_hl(ns, hlname, { fg = "cyan", bg = "green", bold = true })

local jp_virtualtext_pop = function(arg_id, virt_text)
    local line = vim.fn.line "."
    if arg_id then
        vtxtid = vim.api.nvim_buf_set_extmark(0, ns, line - 1, 0, {
            id = arg_id,
            virt_text = virt_text,
        })
    else
        vtxtid = vim.api.nvim_buf_set_extmark(0, ns, line - 1, 0, {
            virt_text = virt_text,
        })
    end
end

local jp_virtualtext_open = function()
    if vtxtid then
        return
    end
    jp_virtualtext_pop(nil, virt_text)
end

local jp_virtualtext_close = function()
    if not vtxtid then
        return
    end
    vim.api.nvim_buf_del_extmark(0, ns, vtxtid)
    vtxtid = nil
end

local jp_virtualtext_move = function()
    if not vtxtid then
        return
    end
    jp_virtualtext_pop(vtxtid, virt_text)
end

function M.setup(opt)
    if opt then
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
        if M.isJapaneseMode then
            os.execute(M.off_command)
            jp_virtualtext_close()
        end
    end

    M.JapaneseInsertOn = function()
        if M.isJapaneseMode then
            os.execute(M.on_command)
            jp_virtualtext_open()
        end
    end

    local ToggleJapaneseMode = function()
        M.isJapaneseMode = not M.isJapaneseMode

        local mode = vim.fn.mode()
        if mode == "i" then
            if M.isJapaneseMode then
                os.execute(M.on_command)
                jp_virtualtext_open()
            else
                os.execute(M.off_command)
                jp_virtualtext_close()
            end
        end
        if mode == "c" then
            if M.isJapaneseMode then
                os.execute(M.on_command)
            else
                os.execute(M.off_command)
            end
        end
    end

    local OffJapaneseMode = function()
        if M.isJapaneseMode then
            local mode = vim.fn.mode()
            if mode == "i" then
                os.execute(M.off_command)
                jp_virtualtext_close()
            elseif mode == "n" or mode == "c" then
                os.execute(M.off_command)
            end
        end
        M.isJapaneseMode = false
    end

    local id_jpmode = vim.api.nvim_create_augroup("JapaneseMode", {})
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = id_jpmode,
        pattern = "*",
        callback = M.JapaneseInsertOff,
    })
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = id_jpmode,
        pattern = "*",
        callback = M.JapaneseInsertOn,
    })
    vim.api.nvim_create_autocmd("CursorMovedI", {
        group = id_jpmode,
        pattern = "*",
        callback = jp_virtualtext_move,
    })

    vim.keymap.set("i", "<C-]>", ToggleJapaneseMode, { noremap = true })
    vim.keymap.set("n", "<C-]>", OffJapaneseMode, { noremap = true })
    vim.keymap.set("c", "<C-]>", ToggleJapaneseMode, { noremap = true })
end

return M
