local Hitbox = {}



function Hitbox.raycast(character,origin, direction)
    local params = nil
    if character then
        params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}
    end
    return workspace:Raycast(origin, direction, params)
end

function Hitbox.blockcast(character, cframe, direction, size)
    local params = nil
    if character then
        params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}
    end
    return workspace:Blockcast(cframe, size, direction, params)
end

function Hitbox.spherecast(character, position, direction, radius)
    local params = nil
    if character then
        params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}
    end
    return workspace:Spherecast(position, radius, direction, params)
end

return Hitbox