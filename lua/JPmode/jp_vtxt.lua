local M = {}

local vtxtid = nil
local ns = vim.api.nvim_create_namespace "JPmodeNamespace"
local hlname = "JPmodeHighlight"
local hlopt = nil

-- local fg = vim.api.nvim_get_hl_by_name("Special", true).foreground
-- local bg = vim.api.nvim_get_hl_by_name("CursorLine", true).background

local set_hl = function(a_opt)
    local opt = a_opt or {}
    opt.highlight = a_opt.highlight or {}

    local default_fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg
    local default_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
    local default_bold = true

    local bg = opt.highlight.bg or default_bg
    local fg = opt.highlight.fg or default_fg
    local bold = opt.highlight.bold or default_bold
    vim.api.nvim_set_hl(0, hlname, { fg = fg, bg = bg, bold = bold })
end

vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    pattern = "*",
    callback = function()
        set_hl(hlopt)
    end,
})

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
    hlopt = opt
    set_hl(opt)
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
