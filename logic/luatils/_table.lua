local _table = {}

_table.assign = function(obj1, obj2)
    for k, v in pairs(obj2) do
        obj1[k] = obj2[k]
    end
end

_table.len = function(obj)
    local count = 0
    for k, v in pairs(obj) do
        count = count + 1
    end
    return count
end

_table.add = function(arr1, arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k] + arr2[k]
    end
end

_table.sub = function(arr1, arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k] - arr2[k]
    end
end

_table.mul = function(arr1, arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k] * arr2[k]
    end
end

_table.div = function(arr1, arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k] / arr2[k]
    end
end

_table.mod = function(arr1, arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k] % arr2[k]
    end
end

_table.merge = function(arr1,arr2)
    for k, v in pairs(arr2) do
        arr1[k] = arr2[k]
    end
end

_table.recurse = function (arr,subname)
    return tonumber(arr[subname]) or arr[subname]
end

_table.move = function(tbl, fromIndex, toIndex)
    fromIndex = fromIndex or 0
    toIndex = toIndex or 0
    if type(tbl) ~= "table" then
        error("The provided argument is not a table.")
    end

    if fromIndex == toIndex or fromIndex < 1 or toIndex < 1 or fromIndex > #tbl + 1 or toIndex > #tbl + 1 then
        -- No need to move if the indices are the same or out of range.
        return
    end

    local valueToMove = table.remove(tbl, fromIndex)
    table.insert(tbl, toIndex, valueToMove)
end

_table.find = function(tbl, value)
    if type(tbl) ~= "table" then
        error("The provided argument is not a table.")
    end

    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end

    return nil  -- Return nil if the element is not found
end



return _table