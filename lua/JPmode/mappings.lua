M = {}

local jp_keymaps = {
    {
        mode = { "n", "o", "v" },
        maps = {
            { lhs = [[f,]], rhs = [[f、]] },
            { lhs = [[f.]], rhs = [[f。]] },
            { lhs = [[F,]], rhs = [[F、]] },
            { lhs = [[F.]], rhs = [[F。]] },
            { lhs = [[t,]], rhs = [[t、]] },
            { lhs = [[t.]], rhs = [[t。]] },
            { lhs = [[T,]], rhs = [[T、]] },
            { lhs = [[T.]], rhs = [[T。]] },
        },
    },
}

M.set = function()
    for _, table in pairs(jp_keymaps) do
        for _, mode in pairs(table.mode) do
            for _, map in pairs(table.maps) do
                vim.keymap.set(mode, map.lhs, map.rhs, { noremap = true })
            end
        end
    end
end

M.del = function()
    for _, table in pairs(jp_keymaps) do
        for _, mode in pairs(table.mode) do
            for _, map in pairs(table.maps) do
                vim.keymap.del(mode, map.lhs, {})
            end
        end
    end
end

return M
