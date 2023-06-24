local Job = require "plenary.job"
local M = {}
local ime = nil

M.setup = function(opt)
    ime = opt.IME
    if not ime.jp.cmd and not ime.en.cmd then
        error "JPmode.IME cannot set IME command. Please set options explicity."
    end
end

M.change2en = function()
    Job:new({
        command = ime.en.cmd,
        args = ime.en.args,
    }):sync()
end

M.change2jp = function()
    Job:new({
        command = ime.jp.cmd,
        args = ime.jp.args,
    }):sync()
end

return M
