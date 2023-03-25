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

return modulo