local M = {}

local default_opt = {
    IME = {
        jp = { cmd = nil, args = nil },
        en = { cmd = nil, args = nil },
    },
    highlight = {
        bg = function()
            return vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
        end,
        fg = function()
            return vim.api.nvim_get_hl(0, { name = "Special" }).fg
        end,
        bold = true,
    },
}

M.set = function(opt)
    local set_opt = function(default, arg)
        local ret = default
        if not arg then
            return ret
        end
        for key, val in pairs(arg) do
            if type(val) == "string" then
                ret[key] = val
            end
            if type(val) == "table" then
                for k, v in pairs(val) do
                    ret[key][k] = v
                end
            end
        end
        return ret
    end
    return set_opt(default_opt, opt)
end

return M
