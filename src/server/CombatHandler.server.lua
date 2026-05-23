-- Normal Combat event variables --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")
local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)
local blockingPlayers = {}

-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")
local FireballTemplate = ReplicatedStorage:WaitForChild("FireballTemplate")

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
            if blockingPlayers[otherPlayer] then continue end
            humanoid:TakeDamage(CombatConfig.Damage)
        end
    end
end)

BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
    blockingPlayers[player] = isBlocking
end)

-- Special moves script --

-- Fireball -- 
FireballEvent.OnServerEvent:Connect(function(player)
    local Character = player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Fireball = FireballTemplate:Clone()
    local HasHit = false
    Fireball.Position = HumanoidRootPart.Position
    Fireball.Parent = game.Workspace

    game:GetService("Debris"):AddItem(Fireball, CombatConfig.FireballLT)

    local hitObject = Fireball.Touched:Connect(function(character)
        local Hit = character.Parent
        if Hit:FindFirstChild("Humanoid") then
            if Hit == Character then return end
            if HasHit == true then return end
            HasHit = true
            Hit.Humanoid:TakeDamage(CombatConfig.FireballDamage)
            game:GetService("Debris"):AddItem(Fireball,0)
        end
    end)

    while Fireball.Parent == game.Workspace do
        Fireball.Position = Fireball.Position + (HumanoidRootPart.CFrame.LookVector*CombatConfig.FireballSpeed)
        task.wait(0.03)
    end
end)