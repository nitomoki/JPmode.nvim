local virtual_text = require "JPmode.virtual_text"
local maps = require "JPmode.mappings"
local config = require "JPmode.config"
local IME = require "JPmode.IME"
local auto_commands = require "JPmode.auto_commands"
local M = {}
local isJapaneseMode = false

local jp_insertion_end = function()
    IME.change2en()
    virtual_text.close()
end

local jp_insertion_start = function()
    IME.change2jp()
    if vim.fn.mode() ~= "c" then
        virtual_text.open()
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

    auto_commands.set()
    maps.set()
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

    auto_commands.del()
    maps.del()
    isJapaneseMode = false
end

local jp_mode_toggle = function()
    if isJapaneseMode then
        jp_mode_off()
    else
        jp_mode_on()
    end
end

M.setup = function(opt)
    isJapaneseMode = false
    opt = config.set(opt)

    IME.setup(opt)
    virtual_text.setup(opt)
    auto_commands.setup(jp_insertion_start, jp_insertion_end, virtual_text.move)
end

M.on = jp_mode_on
M.off = jp_mode_off
M.toggle = jp_mode_toggle

M.isJapaneseMode = function()
    return isJapaneseMode
end

return M
