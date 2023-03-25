local modulo = {}

function modulo.generic(type, status, birth, position, quality, condition, decayRate, mods)
    return {
        type = type or "generic",
        status = status or "",
        mods = mods or {},
        quality = quality or 100,
        condition = condition or 100,
        position = position or {x=0,y=0,z=0},
        birth = birth or 0,
        decayRate = decayRate or 0
    }
end

function modulo.block(material, status, birth, position , quality, condition)
    local obj = {}
    obj = modulo.generic('block', status, birth, position, quality, condition);
    obj.material = material
    return obj
end

return modulo