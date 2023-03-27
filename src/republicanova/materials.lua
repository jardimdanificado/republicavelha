function block(name,solid)
    return{name = name, solid = solid or true}
end

return {
    block('air',false),
    block('earth'),
}