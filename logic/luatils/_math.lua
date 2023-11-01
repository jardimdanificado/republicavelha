local _math = {}

_math.regrad3 = function(a, b, d)
    local c = (a * d) / b
    return c
end

_math.scale = function(value, min, max)
    if (value > max) then
        while (value > max) do
            value = value - max - min
        end
    end
    if (value < min) then
        while (value < min) do
            value = value + (max - min)
        end
    end
    value = _math.regrad3(max - min, 100, value - min)
    return value;
end

_math.vec2 = function(x, y)
    return {
        x = x,
        y = y
    }
end

_math.vec2add = function(vec0, vec1)
    return {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y
    }
end

_math.vec2sub = function(vec0, vec1)
    return {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y
    }
end

_math.vec2div = function(vec0, vec1)
    return {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y
    }
end

_math.vec2mod = function(vec0, vec1)
    return {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y
    }
end

_math.vec2mul = function(vec0, vec1)
    return {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y
    }
end

_math.vec3 = function(x, y, z)
    return {
        x = x,
        y = y,
        z = z
    }
end

_math.vec3add = function(vec0, vec1)
    return {
        x = vec0.x + vec1.x,
        y = vec0.y + vec1.y,
        z = vec0.z + vec1.z
    }
end

_math.vec3sub = function(vec0, vec1)
    return {
        x = vec0.x - vec1.x,
        y = vec0.y - vec1.y,
        z = vec0.z - vec1.z
    }
end

_math.vec3mul = function(vec0, vec1)
    return {
        x = vec0.x * vec1.x,
        y = vec0.y * vec1.y,
        z = vec0.z * vec1.z
    }
end

_math.vec3div = function(vec0, vec1)
    return {
        x = vec0.x / vec1.x,
        y = vec0.y / vec1.y,
        z = vec0.z / vec1.z
    }
end

_math.vec3mod = function(vec0, vec1)
    return {
        x = vec0.x % vec1.x,
        y = vec0.y % vec1.y,
        z = vec0.z % vec1.z
    }
end

_math.limit = function(value, min, max)
    local range = max - min
    if range <= 0 then
        return min
    end
    local offset = (value - min) % range
    return offset + min + (offset < 0 and range or 0)
end

_math.rotate = function(position, pivot, angle)
    -- convert angle to radians
    angle = math.rad(angle)

    -- calculate sine and cosine of angle
    local s = math.sin(angle)
    local c = math.cos(angle)

    -- translate position so that pivot is at the origin
    local translated = _math.vec3sub(position, pivot)

    -- apply rotation
    local rotated = {
        x = translated.x * c - translated.z * s,
        y = position.y,
        z = translated.x * s + translated.z * c
    }

    -- translate back to original position
    return _math.vec3add(rotated, {
        x = pivot.x,
        y = 0,
        z = pivot.z
    })
end

_math.primo = function (num)
    for i = 2, num, 1 do
        if num%i == 0 then
            return false,i
        end
    end
    return true
end

_math.mmc = function (...)
    local bulkcheck = function (i,...)
        local a = 0
        for index, value in pairs({...}) do
            a = a + (i%value == 0 and 1 or 0)
        end
        if a == #{...} then
            return true
        end
    end
    local min = math.min(...)
    local i = min
    while not bulkcheck(i,...) do
        i = i + 1
    end
    return i
end

return _math