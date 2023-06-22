local Job = require "plenary.job"
local jp_vtxt = require "JPmode.virtual_text"
local jp_maps = require "JPmode.mappings"
local M = {}

local isJapaneseMode = false
local id_jpmode = vim.api.nvim_create_augroup("JPmode", {})
local aucmd = nil

local IME = {
    jp = { cmd = nil, args = nil },
    en = { cmd = nil, args = nil },
}

local jp_insertion_end = function()
    Job:new({
        command = IME.en.cmd,
        args = IME.en.args,
    }):sync()
    jp_vtxt.close()
end

local jp_insertion_start = function()
    Job:new({
        command = IME.jp.cmd,
        args = IME.jp.args,
    }):sync()
    if vim.fn.mode() == "i" then
        jp_vtxt.open()
    end
end

local jp_mode_on = function()
    local mode = vim.fn.mode()
    if mode == "i" or mode == "c" then
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
        aucmd.CmdL = vim.api.nvim_create_autocmd("CmdlineLeave", {
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
    end

    jp_maps.set()

    isJapaneseMode = true
end

local jp_mode_off = function()
    local mode = vim.fn.mode()
    if mode == "i" or mode == "c" then
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
        IME.jp = opt.jp or nil
        IME.en = opt.en or nil
        jp_vtxt.setup(opt)
    else
        jp_vtxt.setup()
    end

    if not IME.jp and not IME.en then
        print "JPmode: error! cannot be set Japanese IME command. Please set options explicity."
        return -1
    end
end

M.on = jp_mode_on
M.off = jp_mode_off
M.toggle = jp_mode_toggle

return M
