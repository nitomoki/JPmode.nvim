local M = {}

local check_command = function(arg)
    local cmd = ("call system('type %s')"):format(arg)
    vim.cmd(cmd)
    return vim.v.shell_error
end

local vtxtid = nil
local ns = vim.api.nvim_create_namespace "JPmodeNamespace"
local hlname = "JPmodeHighlight"

local fg = vim.api.nvim_get_hl_by_name("Special", true).foreground
local bg = vim.api.nvim_get_hl_by_name("CursorLine", true).background
vim.api.nvim_set_hl(0, hlname, { fg = fg, bg = bg, bold = true })

local isJapaneseMode = false

local jp_keymaps = {
    {
        mode = { "n", "o", "v" },
        maps = {
            { lhs = [[f,]], rhs = [[f、]] },
            { lhs = [[f.]], rhs = [[f。]] },
            { lhs = [[F,]], rhs = [[F、]] },
            { lhs = [[F.]], rhs = [[F。]] },
        },
    },
}

local virt_text = { { " JP", hlname } }

local jp_virtualtext_pop = function(arg_id, v_text)
    local line = vim.fn.line "."
    if arg_id then
        vtxtid = vim.api.nvim_buf_set_extmark(0, ns, line - 1, 0, {
            id = arg_id,
            virt_text = v_text,
        })
    else
        vtxtid = vim.api.nvim_buf_set_extmark(0, ns, line - 1, 0, {
            virt_text = v_text,
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

local jp_insertion_end = function()
    os.execute(M.off_command)
    jp_virtualtext_close()
end

local jp_insertion_start = function()
    os.execute(M.on_command)
    jp_virtualtext_open()
end

local jp_mode_on = function()
    if vim.fn.mode() == "i" then
        jp_insertion_start()
    end

    if isJapaneseMode then
        return
    end

    if M.id_jpmode and not M.aucmd then
        M.aucmd = {}
        M.aucmd.InsL = vim.api.nvim_create_autocmd("InsertLeave", {
            group = M.id_jpmode,
            pattern = "*",
            callback = jp_insertion_end,
        })
        M.aucmd.InsE = vim.api.nvim_create_autocmd("InsertEnter", {
            group = M.id_jpmode,
            pattern = "*",
            callback = jp_insertion_start,
        })
        M.aucmd.CurM = vim.api.nvim_create_autocmd("CursorMovedI", {
            group = M.id_jpmode,
            pattern = "*",
            callback = jp_virtualtext_move,
        })
        M.aucmd.TeleFP = vim.api.nvim_create_autocmd("User TelescopeFindPre", {
            group = M.id_jpmode,
            pattern = "*",
            callback = jp_insertion_end,
        })
    end

    for _, table in pairs(jp_keymaps) do
        for _, mode in pairs(table.mode) do
            for _, map in pairs(table.maps) do
                vim.keymap.set(mode, map.lhs, map.rhs, { noremap = true })
            end
        end
    end

    isJapaneseMode = true
end

local jp_mode_off = function()
    if vim.fn.mode() == "i" then
        jp_insertion_end()
    end

    if not isJapaneseMode then
        return
    end

    if M.aucmd then
        for _, id in pairs(M.aucmd) do
            vim.api.nvim_del_autocmd(id)
        end
        M.aucmd = nil
    end

    for _, table in pairs(jp_keymaps) do
        for _, mode in pairs(table.mode) do
            for _, map in pairs(table.maps) do
                vim.keymap.del(mode, map.lhs, {})
            end
        end
    end

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

    if opt.highlight then
        local opt_bg = opt.highlight.bg or nil
        local opt_fg = opt.highlight.fg or nil
        local opt_bold = opt.highlight.bold or nil
        if opt_bg and opt_fg and opt_bold then
            vim.api.nvim_set_hl(0, hlname, { fg = fg, bg = bg, bold = opt_bold })
        end
    end

    M.id_jpmode = vim.api.nvim_create_augroup("JapaneseMode", {})

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
