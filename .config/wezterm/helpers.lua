---@param s string
---@return string
function string.basename(s)
    local base = string.gsub(s, "(.*[/\\])(.*)", "%2")
    local idx = base:find(".exe")

    if idx == nil then
        return base
    end

    return base:sub(0, idx - 1)
end

---@generic T : table
---@param t T
---@return T
function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

