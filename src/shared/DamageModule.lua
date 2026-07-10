-- Centralized damage helper for applying combat damage to NPCs and players.
local DamageModule = {}
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local StateHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))
local CombatConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CombatConfig"))


function DamageModule.dealregularDamagenpc(player, targetCharacter)
    local playerStrength = statModule.getStat(player, "Strength")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if not targetHumanoid then return end
    targetHumanoid:TakeDamage(5+(playerStrength*2))
end

function DamageModule.dealspecialDamagenpc(player, targetCharacter)
    local playerSpecial = statModule.getStat(player, "Special")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if not targetHumanoid then return end
    targetHumanoid:TakeDamage(10+(playerSpecial*5))
end

function DamageModule.dealregularDamageplayer(player, targetCharacter)
    local playerStrength = statModule.getStat(player, "Strength")
    local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(targetCharacter)
    local isBlocking = StateHandler.GetState(targetPlayer, "Blocking")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")

    if not targetHumanoid then return end
    if isBlocking then
        targetHumanoid:TakeDamage((5+(playerStrength*2))*CombatConfig.BlockReductionRegular)
    else
        targetHumanoid:TakeDamage(5+(playerStrength*2))
    end
end

function DamageModule.dealspecialDamageplayer(player, targetCharacter)
    local playerSpecial = statModule.getStat(player, "Special")
    local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(targetCharacter)
    local isBlocking = StateHandler.GetState(targetPlayer, "Blocking")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")

    if not targetHumanoid then return end
    if isBlocking then
        targetHumanoid:TakeDamage((10+(playerSpecial*5))*CombatConfig.BlockReductionSpecial)
    else
        targetHumanoid:TakeDamage(10+(playerSpecial*5))
    end
end

function DamageModule.Knockback(player, targetCharacter)
    print("Knockback called with:", player, targetCharacter)
    if not player.Character then return end

    local attackerCharacter = player.Character
    local attackerHumanoidRootPart = attackerCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not attackerHumanoidRootPart or not targetHumanoidRootPart then return end

    local attackerPosition = attackerHumanoidRootPart.Position
    local targetPosition = targetHumanoidRootPart.Position

    local direction = (targetPosition-attackerPosition).Unit
    direction = Vector3.new(direction.X, 0, direction.Z)

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = direction * 200
    bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- horizontal only, no vertical
    bv.Parent = targetHumanoidRootPart
    game:GetService("Debris"):AddItem(bv, 0.15)
end

return DamageModule
