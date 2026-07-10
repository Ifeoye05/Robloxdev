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

function Hitbox.visualize(character, _type, options)
    if not _type then return end
    if not character then return end
    if _type == "ray" then
        local origin = options.origin
        local direction = options.direction
         local visualPart = Instance.new("Part")
        visualPart.Size = Vector3.new(0.1, 0.1, direction.Magnitude)
        visualPart.CFrame = CFrame.lookAt(origin, origin + direction) * CFrame.new(0, 0, -direction.Magnitude/2)
        visualPart.Anchored = true
        visualPart.CanCollide = false
        visualPart.Transparency = 0.5
        visualPart.Color = Color3.fromRGB(255, 0, 0)
        visualPart.Parent = workspace
        game:GetService("Debris"):AddItem(visualPart, 0.1)
    elseif _type == "block" then
        local visualPart = Instance.new("Part")
        visualPart.Size = options.size
        visualPart.CFrame = options.cframe
        visualPart.Anchored = false
        visualPart.CanCollide = false
        visualPart.Transparency = 0.5
        visualPart.Massless = true
        visualPart.Color = Color3.fromRGB(255, 0, 0)
        visualPart.Parent = character
        local weld = Instance.new("WeldConstraint")
        weld.Parent = visualPart
        weld.Part0 = visualPart
        weld.Part1 = character.HumanoidRootPart
        game:GetService("Debris"):AddItem(visualPart, 0.1)
    elseif _type == "sphere" then
        local radius = options.radius
        local position = options.position
        local visualPart = Instance.new("Part")
        visualPart.Shape = Enum.PartType.Ball
        visualPart.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
        visualPart.CFrame = CFrame.new(position)
        visualPart.Anchored = true
        visualPart.CanCollide = false
        visualPart.Transparency = 0.5
        visualPart.Color = Color3.fromRGB(255, 0, 0)
        visualPart.Parent = workspace
        game:GetService("Debris"):AddItem(visualPart, 0.1)
    end
end

return Hitbox