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
local SpecialMoveHandler = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpecialMoveHandler"))
local InventoryModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("InventoryModule"))
local animmodule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimationHandler"))

local hitAnimIndex = 1
local hitAnims = {CombatConfig.Animations.Hitanim1, CombatConfig.Animations.Hitanim2}


-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")

-- Combat script

PunchEvent.OnServerEvent:Connect(function(player)
    -- Prevent spam attacks while the player is already in an attack state.
    if InventoryModule.getEquipped(player) then return end
    if module.GetState(player, "Attacking") then return end

    local Character = player.Character
    local Cframe = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
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
        visualPart.Size = Vector3.new(4,4,CombatConfig.PunchRange)
        visualPart.CFrame = Cframe * CFrame.new(0,0,-3)
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
    local hitbox = workspace:Blockcast(Cframe, size, direction, params)
    -- Apply damage only if the raycast hit an entity with a Humanoid.
    if hitbox then
        local humanoid = hitbox.Instance.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(hitbox.Instance.Parent)
            local character = humanoid.Parent
            if targetPlayer then
                -- Player-vs-player damage uses blocking rules.
                DamageModule.dealregularDamageplayer(player, character)
                module.SetStun(targetPlayer, true, CombatConfig.PunchStun)
                local animtoPlay = hitAnims[hitAnimIndex]
                animmodule.LoadAnim(character, "Hit", animtoPlay)
                hitAnimIndex = hitAnimIndex % 2 + 1
            else
                -- NPC damage uses the simpler damage path.
                DamageModule.dealregularDamagenpc(player, character)
                module.SetStun(character, true, CombatConfig.PunchStun)
                local animtoPlay = hitAnims[hitAnimIndex]
                animmodule.LoadAnim(character, "Hit", animtoPlay)
                hitAnimIndex = hitAnimIndex % 2 + 1
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
    if InventoryModule.getEquipped(player) then return end
    if module.GetState(player, "FireballCD") then return end
    SpecialMoveHandler.Fireball(player)
    module.SetState(player, "FireballCD", true, CombatConfig.FireballCD)
end)