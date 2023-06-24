local config = require "JPmode.config"

local default_opt = {
    IME = {
        jp = { cmd = nil, args = nil },
        en = { cmd = nil, args = nil },
    },
    highlight = {
        bg = "Special",
        fg = "CursorLine",
        bold = true,
    },
}

local test_opt = {
    IME = {
        jp = { cmd = "JP_CMD", args = "JP_ARGS" },
        en = { cmd = "EN_CMD", args = "EN_CMD" },
    },
    highlight = {
        bg = "BG",
        fg = "FG",
        bold = true,
    },
}

local test_opt2 = {
    IME = {
        jp = { cmd = "JP_CMD", args = "JP_ARGS" },
        en = { cmd = "EN_CMD", args = "EN_CMD" },
    },
    highlight = {
        bg = "BG",
        fg = "FG",
        bold = true,
    },
}

local function tables_equal(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    for key, val in pairs(t1) do
        if type(val) == "table" then
            if not tables_equal(val, t2[key]) then
                return false
            end
        elseif val ~= t2[key] then
            return false
        end
    end
    return true
end

describe("tables_equal function", function()
    it("should return true for two empty tables", function()
        assert.is_true(tables_equal({}, {}))
    end)

    it("should return true for two tables with same keys and values", function()
        local t1 = { a = 1, b = 2, c = 3 }
        local t2 = { a = 1, b = 2, c = 3 }
        assert.is_true(tables_equal(t1, t2))
    end)

    it("should return false for two tables with different values for same keys", function()
        local t1 = { a = 1, b = 2, c = 3 }
        local t2 = { a = 1, b = 2, c = 4 }
        assert.is_false(tables_equal(t1, t2))
    end)

    it("should return true for two nested tables with same keys and values", function()
        local t1 = { a = 1, b = 2, c = { d = 3, e = 4, f = 5 } }
        local t2 = { a = 1, b = 2, c = { d = 3, e = 4, f = 5 } }
        assert.is_true(tables_equal(t1, t2))
    end)

    it("should return false for two nested tables with different values for same keys", function()
        local t1 = { a = 1, b = 2, c = { d = 3, e = 4, f = 5 } }
        local t2 = { a = 1, b = 2, c = { d = 3, e = 4, f = 6 } }
        assert.is_false(tables_equal(t1, t2))
    end)

    it("should return true for nested tables of more than two levels with same keys and values", function()
        local t1 = { a = 1, b = { c = 2, d = { e = 3, f = 4 } }, g = 5 }
        local t2 = { a = 1, b = { c = 2, d = { e = 3, f = 4 } }, g = 5 }
        assert.is_true(tables_equal(t1, t2))
    end)

    it(
        "should return false for nested tables of more than two levels with different values at deepest level",
        function()
            local t1 = { a = 1, b = { c = 2, d = { e = 3, f = 4 } }, g = 5 }
            local t2 = { a = 1, b = { c = 2, d = { e = 3, f = 5 } }, g = 5 }
            assert.is_false(tables_equal(t1, t2))
        end
    )
end)

describe("config.set", function()
    it("nil argument should not change default", function()
        local opt = config.set(nil)
        assert.is_true(tables_equal(default_opt, opt))
    end)
    it("argument should change opt", function()
        local opt = config.set(test_opt)
        assert.is_true(tables_equal(test_opt, opt))
    end)
end)
