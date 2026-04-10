local favourites = require("widgets.tasklist.favourites")

function reverse_table(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

-- Build a lookup table of favourite classes for fast checking
local favourite_classes = {}
for _, v in pairs(favourites) do
    if v["class"] then
        favourite_classes[string.lower(v["class"])] = true
    end
end

return function()
    -- Get all clients
    local cls = client.get()

    -- Filter by an existing filter function and allowing only one client per class
    local result = {}
    local class_seen = {}
    for _, c in pairs(cls) do
        if c.class ~= nil and not class_seen[c.class] and not favourite_classes[c.class:lower()] then
            class_seen[c.class] = true
            table.insert(result, c)
        end
    end
    
    return reverse_table(result)
end