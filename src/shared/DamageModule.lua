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

function DamageModule.Knockback(plr, targetcharacter)
    print("Knockback called with:", plr, targetcharacter)
    if not plr.Character then return end
    if not plr.Character.HumanoidRootPart then return end
    if not targetcharacter.HumanoidRootPart then return end
    
    local attackingChar = plr.Character
    local attackHR = attackingChar.HumanoidRootPart
    local victimHR = targetcharacter.HumanoidRootPart

    local attackPosition = attackHR.Position
    local victimPosition = victimHR.Position

    local direction = (victimPosition-attackPosition).Unit
    direction = Vector3.new(direction.X, 0, direction.Z)

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = direction * 200
    bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- horizontal only, no vertical
    bv.Parent = targetcharacter.HumanoidRootPart
    game:GetService("Debris"):AddItem(bv, 0.15)
end

return DamageModule