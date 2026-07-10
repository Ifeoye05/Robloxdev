local SpecialMove = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig"))
local DamageModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DamageModule"))
local FireballTemplate = ReplicatedStorage:WaitForChild("FireballTemplate")
local FireballExplosionTemplate = ReplicatedStorage:WaitForChild("FireballExplosionTemplate")

function SpecialMove.Fireball(player)
    local Character = player.Character
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Fireball = FireballTemplate:Clone()
    local hasHit = false

    -- Start the projectile at the player's current position and orientation.
    Fireball.CFrame = HumanoidRootPart.CFrame
    Fireball.Parent = game.Workspace

    game:GetService("Debris"):AddItem(Fireball, CombatConfig.FireballLT)

    -- Damage is applied once when the projectile first touches a valid target.
    local hitObject = Fireball.Touched:Connect(function(touchedPart)
        local targetCharacter = touchedPart.Parent
        if targetCharacter:FindFirstChild("Humanoid") then
            if targetCharacter == Character then return end
            if hasHit == true then return end
            hasHit = true
            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(targetCharacter)
            if targetPlayer then
                DamageModule.dealspecialDamageplayer(player, targetCharacter)
            else
                DamageModule.dealspecialDamagenpc(player, targetCharacter)
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
end


return SpecialMove
