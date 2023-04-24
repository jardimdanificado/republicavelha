local function block(name,solid)
    return{name = name, solid = solid}
end

return {
    block('air',false),
    block('earth',true),
}