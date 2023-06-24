local M = {}

local insertion_start_callback = function() end
local insertion_end_callback = function() end
local cursor_move_callback = function() end

local id_jpmode = vim.api.nvim_create_augroup("JPmode", {})
local aucmd = nil

M.setup = function(start_cb, end_cb, move_cb)
    insertion_start_callback = function()
        start_cb()
    end
    insertion_end_callback = function()
        end_cb()
    end
    cursor_move_callback = function()
        move_cb()
    end
end

M.set = function()
    if id_jpmode and not aucmd then
        aucmd = {}
        aucmd.InsL = vim.api.nvim_create_autocmd("InsertLeave", {
            group = id_jpmode,
            pattern = "*",
            callback = insertion_end_callback,
        })
        aucmd.CmdL = vim.api.nvim_create_autocmd("CmdlineLeave", {
            group = id_jpmode,
            pattern = "*",
            callback = insertion_end_callback,
        })
        aucmd.InsE = vim.api.nvim_create_autocmd("InsertEnter", {
            group = id_jpmode,
            pattern = "*",
            callback = insertion_start_callback,
        })
        aucmd.CurM = vim.api.nvim_create_autocmd("CursorMovedI", {
            group = id_jpmode,
            pattern = "*",
            callback = cursor_move_callback,
        })
    end
end

M.del = function()
    if aucmd then
        for _, id in pairs(aucmd) do
            vim.api.nvim_del_autocmd(id)
        end
        aucmd = nil
    end
end

return M
