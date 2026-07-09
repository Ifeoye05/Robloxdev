-- Centralized damage helper for applying combat damage to NPCs and players.
local DamageModule = {}
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local stateModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))
local CombatConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CombatConfig"))


function DamageModule.dealregularDamagenpc(plr, targetcharacter)
    local plrStrength = statModule.getStat(plr, "Strength")
    local targethumanoid = targetcharacter:FindFirstChild("Humanoid")
    if not targethumanoid then return end
    targethumanoid:TakeDamage(5+(plrStrength*2))
end

function DamageModule.dealspecialDamagenpc(plr, targetcharacter)
    local plrSpecial = statModule.getStat(plr, "Special")
    local targethumanoid = targetcharacter:FindFirstChild("Humanoid")
    if not targethumanoid then return end
    targethumanoid:TakeDamage(10+(plrSpecial*5))
end

function DamageModule.dealregularDamageplayer(plr, targetcharacter)
    local plrStrength = statModule.getStat(plr, "Strength")
    local targetplayer = game:GetService("Players"):GetPlayerFromCharacter(targetcharacter)
    local isBlocking = stateModule.GetState(targetplayer, "Blocking")
    local targethumanoid = targetcharacter:FindFirstChild("Humanoid")

    if not targethumanoid then return end
    if isBlocking then
        targethumanoid:TakeDamage((5+(plrStrength*2))*CombatConfig.BlockReductionregular)
    else
        targethumanoid:TakeDamage(5+(plrStrength*2))
    end
end

function DamageModule.dealspecialDamageplayer(plr, targetcharacter)
    local plrSpecial = statModule.getStat(plr, "Special")
    local targetplayer = game:GetService("Players"):GetPlayerFromCharacter(targetcharacter)
    local isBlocking = stateModule.GetState(targetplayer, "Blocking")
    local targethumanoid = targetcharacter:FindFirstChild("Humanoid")

    if not targethumanoid then return end
    if isBlocking then
        targethumanoid:TakeDamage((10+(plrSpecial*5))*CombatConfig.BlockReductionspecial)
    else
        targethumanoid:TakeDamage(10+(plrSpecial*5))
    end
end



return DamageModule