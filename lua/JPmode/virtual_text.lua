local M = {}

local vtxtid = nil
local ns = vim.api.nvim_create_namespace "JPmodeNamespace"
local hlname = "JPmodeHighlight"
local hlopt = nil
local isAutocmdSet = false
local virt_text = { { " <<JP", hlname } }

local isVtxtExist = function()
    if vtxtid then
        return true
    else
        return false
    end
end

local set_hl = function(opt)
    local fg, bg, bold
    if type(opt.highlight.fg) == "function" then
        fg = opt.highlight.fg()
    else
        fg = opt.highlight.fg
    end
    if type(opt.highlight.bg) == "function" then
        bg = opt.highlight.bg()
    else
        bg = opt.highlight.bg
    end
    if type(opt.highlight.bold) == "function" then
        bold = opt.highlight.bold()
    else
        bold = opt.highlight.bold
    end
    vim.api.nvim_set_hl(0, hlname, { fg = fg, bg = bg, bold = bold })
end

local virtualtext_popup = function(arg_id)
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

local virtualtext_hide = function()
    vim.api.nvim_buf_del_extmark(0, ns, vtxtid)
    vtxtid = nil
end

M.setup = function(opt)
    hlopt = opt
    set_hl(opt)

    if not isAutocmdSet then
        vim.api.nvim_create_autocmd({ "ColorScheme" }, {
            pattern = "*",
            callback = function()
                set_hl(hlopt)
            end,
        })
        isAutocmdSet = true
    end
end

M.open = function()
    if isVtxtExist() then
        return
    end
    virtualtext_popup(nil)
end

M.close = function()
    if not isVtxtExist() then
        return
    end
    virtualtext_hide()
end

M.move = function()
    if not vtxtid then
        return
    end
    virtualtext_popup(vtxtid)
end

return M
