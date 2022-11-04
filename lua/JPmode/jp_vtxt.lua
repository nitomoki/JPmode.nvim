local M = {}

local vtxtid = nil
local ns = vim.api.nvim_create_namespace "JPmodeNamespace"
local hlname = "JPmodeHighlight"

local fg = vim.api.nvim_get_hl_by_name("Special", true).foreground
local bg = vim.api.nvim_get_hl_by_name("CursorLine", true).background
vim.api.nvim_set_hl(0, hlname, { fg = fg, bg = bg, bold = true })

local virt_text = { { " JP", hlname } }

local virtualtext_pop = function(arg_id, v_text)
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

M.setup = function(opt)
    if not opt.highlight then
        return
    end
    local o_bg = opt.highlight.bg or nil
    local o_fg = opt.highlight.fg or nil
    local o_bold = opt.highlight.bold or nil
    if o_bg and o_fg and o_bold then
        vim.api.nvim_set_hl(0, hlname, { fg = o_fg, bg = o_bg, bold = o_bold })
    end
end

M.open = function()
    if vtxtid then
        return
    end
    virtualtext_pop(nil, virt_text)
end

M.close = function()
    if not vtxtid then
        return
    end
    vim.api.nvim_buf_del_extmark(0, ns, vtxtid)
    vtxtid = nil
end

M.move = function()
    if not vtxtid then
        return
    end
    virtualtext_pop(vtxtid, virt_text)
end

return M
