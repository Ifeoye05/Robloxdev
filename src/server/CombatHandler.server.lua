local module = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))

-- Normal Combat event variables --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")
local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)


-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")
local FireballTemplate = ReplicatedStorage:WaitForChild("FireballTemplate")
local FireballExplosionTemplate = ReplicatedStorage:WaitForChild("FireballExplosionTemplate")

-- Combat script

PunchEvent.OnServerEvent:Connect(function(player)
    local Character = player.Character
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Characters = game.Workspace:GetChildren()
    for _, otherCharacter in ipairs(Characters) do
        if Character == otherCharacter then continue end
        local humanoid = otherCharacter:FindFirstChild("Humanoid")
        if humanoid == nil then continue end
        local otherHumanoidRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
        if otherHumanoidRootPart == nil then continue end

        if (HumanoidRootPart.Position - otherHumanoidRootPart.Position).Magnitude <= 7 then
            local otherPlayer = game:GetService("Players"):GetPlayerFromCharacter(otherCharacter)
            module.SetState(player, "Attacking", true, CombatConfig.PunchCD)
            if module.GetState(otherPlayer, "Blocking") then 
                humanoid:TakeDamage(CombatConfig.Damage*CombatConfig.BlockReduction)
            else
                humanoid:TakeDamage(CombatConfig.Damage)
                module.SetStun(otherPlayer,true, CombatConfig.PunchStun, 0)
            end
        end
    end
end)

BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
    if isBlocking then
        module.SetState(player, "Blocking", true)
    else 
        module.RemoveStates(player, "Blocking")
    end
end)

-- Special moves script --

-- Fireball -- 
FireballEvent.OnServerEvent:Connect(function(player)
    local Character = player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Fireball = FireballTemplate:Clone()
    local HasHit = false
    Fireball.CFrame = HumanoidRootPart.CFrame
    Fireball.Parent = game.Workspace

    game:GetService("Debris"):AddItem(Fireball, CombatConfig.FireballLT)

    local hitObject = Fireball.Touched:Connect(function(character)
        local Hit = character.Parent
        if Hit:FindFirstChild("Humanoid") then
            if Hit == Character then return end
            if HasHit == true then return end
            HasHit = true
            Hit.Humanoid:TakeDamage(CombatConfig.FireballDamage)
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