-- Server-side combat handler.
-- This script processes melee attacks, blocking state, and the fireball special move.
local module = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))

-- Normal Combat event variables --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")
local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)
local DamageModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DamageModule"))


-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")
local FireballTemplate = ReplicatedStorage:WaitForChild("FireballTemplate")
local FireballExplosionTemplate = ReplicatedStorage:WaitForChild("FireballExplosionTemplate")

-- Combat script

PunchEvent.OnServerEvent:Connect(function(player)
    -- Prevent spam attacks while the player is already in an attack state.
    if module.GetState(player, "Attacking") then return end

    local Character = player.Character
    local Cframe = Character.HumanoidRootPart.CFrame
    local params = RaycastParams.new()
    local size = Vector3.new(4,4,4)
    local direction = Cframe.LookVector*CombatConfig.PunchRange
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Character}

    -- Perform a short-range hitbox check in front of the player to detect a valid target.
    local hitbox = workspace:Blockcast(Cframe, size, direction, params)

    -- Create a brief visual effect for the punch so the hitbox is easier to understand during play.
    local function visualize()
        local visualPart = Instance.new("Part")
        visualPart.Size = size
        visualPart.CFrame = Cframe * CFrame.new(0, 0, -(CombatConfig.PunchRange/2) - 2)
        visualPart.Anchored = false
        visualPart.CanCollide = false
        visualPart.Transparency = 0.5
        visualPart.Color = Color3.fromRGB(255, 0, 0)
            visualPart.Parent = Character
        local weld = Instance.new("WeldConstraint")
        weld.Parent = visualPart
        weld.Part0 = visualPart
        weld.Part1 = Character.HumanoidRootPart
        game:GetService("Debris"):AddItem(visualPart, 0.1)
    end
    visualize()

    -- Apply damage only if the raycast hit an entity with a Humanoid.
    if hitbox then
        local humanoid = hitbox.Instance.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(hitbox.Instance.Parent)
            local character = humanoid.Parent
            if targetPlayer then
                -- Player-vs-player damage uses blocking rules.
                DamageModule.dealregularDamageplayer(player, character)
            else
                -- NPC damage uses the simpler damage path.
                DamageModule.dealregularDamagenpc(player, character)
            end
        end
    end
end)

BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
    -- Toggle the blocking state on the server so damage logic can honor it.
    if isBlocking then
        module.SetState(player, "Blocking", true)
    else
        module.RemoveStates(player, "Blocking")
    end
end)

-- Special moves script --

-- Fireball -- 
FireballEvent.OnServerEvent:Connect(function(player)
    -- Respect the fireball cooldown before spawning another projectile.
    if module.GetState(player, "FireballCD") then return end

    local Character = player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Fireball = FireballTemplate:Clone()
    local HasHit = false

    -- Start the projectile at the player's current position and orientation.
    Fireball.CFrame = HumanoidRootPart.CFrame
    Fireball.Parent = game.Workspace

    game:GetService("Debris"):AddItem(Fireball, CombatConfig.FireballLT)

    -- Damage is applied once when the projectile first touches a valid target.
    local hitObject = Fireball.Touched:Connect(function(character)
        local Hit = character.Parent
        if Hit:FindFirstChild("Humanoid") then
            if Hit == Character then return end
            if HasHit == true then return end
            HasHit = true
            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(Hit)
            if targetPlayer then
                DamageModule.dealspecialDamageplayer(player, Hit)
            else
                DamageModule.dealspecialDamagenpc(player, Hit)
            end
            local FireballExplosion = FireballExplosionTemplate:Clone()
            FireballExplosion.Parent = game.Workspace
            FireballExplosion.Position = Fireball.Position
            task.wait(0.1)
            local Explosionparticles = FireballExplosion:WaitForChild("Attachment"):GetChildren()
            for _, particles in ipairs(Explosionparticles) do
                particles:Emit(20)
            end
            game:GetService("Debris"):AddItem(FireballExplosion, 1)
            game:GetService("Debris"):AddItem(Fireball,0)
        end
    end)

    local LookVector = HumanoidRootPart.CFrame.LookVector
    while Fireball.Parent == game.Workspace do
        Fireball.Position = Fireball.Position + (LookVector*CombatConfig.FireballSpeed)
        task.wait(0.03)
    end
    module.SetState(player, "FireballCD", true, CombatConfig.FireballCD)
end)