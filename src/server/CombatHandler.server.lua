-- Server-side combat handler.
-- This script processes melee attacks, blocking state, and the fireball special move.
local StateHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))

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
local HitboxHandler = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("HitboxHandler"))
local Hitvfx = game:GetService("ServerStorage"):WaitForChild("Hitvfx")

local hitAnimIndex = 1
local hitAnims = {CombatConfig.Animations.HitAnim1, CombatConfig.Animations.HitAnim2}

local hitCounter = {}
local comboTime = {}


-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")

-- Combat script

PunchEvent.OnServerEvent:Connect(function(player)
    -- Prevent spam attacks while the player is already in an attack state.
    if InventoryModule.getEquipped(player) then return end
    if StateHandler.GetState(player, "Attacking") then return end

    local Character = player.Character
    local cframe = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
    local size = Vector3.new(4,4,4)
    local direction = cframe.LookVector*CombatConfig.PunchRange

    -- Perform a short-range hitbox check in front of the player to detect a valid target.
    local hitbox = HitboxHandler.blockcast(Character, cframe, direction, size)

    -- Create a brief visual effect for the punch so the hitbox is easier to understand during play.
    HitboxHandler.visualize(Character, "block", {size = size, cframe = cframe * CFrame.new(0,0,-3)})

    -- Apply damage only if the raycast hit an entity with a Humanoid.
    if hitbox then
        local targetHumanoid = hitbox.Instance.Parent:FindFirstChild("Humanoid")
        if targetHumanoid then
            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(hitbox.Instance.Parent)
            local targetCharacter = targetHumanoid.Parent
            if targetPlayer then
                -- Player-vs-player damage uses blocking rules.
                DamageModule.dealregularDamageplayer(player, targetCharacter)
                StateHandler.SetStun(targetPlayer, true, CombatConfig.PunchStun)
                local targetPlayerPosition = targetPlayer.Character.HumanoidRootPart.Position
                local vfx = Hitvfx:Clone()
                vfx.Position = targetPlayerPosition
                vfx.Parent = targetPlayer.Character
                local weld = Instance.new("WeldConstraint")
                weld.Parent = vfx
                weld.Part0 = vfx
                weld.Part1 = targetPlayer.Character.HumanoidRootPart
                game:GetService("Debris"):AddItem(vfx, 0.5)
            else
                -- NPC damage uses the simpler damage path.
                DamageModule.dealregularDamagenpc(player, targetCharacter)
                StateHandler.SetStun(targetCharacter, true, CombatConfig.PunchStun)
                local targetCharacterPosition = targetCharacter.HumanoidRootPart.Position
                local vfx = Hitvfx:Clone()
                vfx.Position = targetCharacterPosition
                vfx.Parent = targetCharacter
                local weld = Instance.new("WeldConstraint")
                weld.Parent = vfx
                weld.Part0 = vfx
                weld.Part1 = targetCharacter.HumanoidRootPart
                game:GetService("Debris"):AddItem(vfx, 0.5)
            end
            -- shared hit counter and animation logic
            local animToPlay = hitAnims[hitAnimIndex]
            animmodule.LoadAnim(targetCharacter, "Hit", animToPlay)
            hitAnimIndex = hitAnimIndex % 2 + 1

            if (time() - (comboTime[player] or 0)) > 2 then
                hitCounter[player] = 0
            end
            hitCounter[player] = (hitCounter[player] or 0) + 1
            comboTime[player] = time()
            if hitCounter[player] == 5 then
                DamageModule.Knockback(player, targetCharacter)
                hitCounter[player] = 0
                comboTime[player] = 0
            end
        end
    end
end)

BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
    -- Toggle the blocking state on the server so damage logic can honor it.
    if isBlocking then
        StateHandler.SetState(player, "Blocking", true)
    else
        StateHandler.RemoveStates(player, "Blocking")
    end
end)

-- Special moves script --

-- Fireball --
FireballEvent.OnServerEvent:Connect(function(player)
    -- Respect the fireball cooldown before spawning another projectile.
    if InventoryModule.getEquipped(player) then return end
    if StateHandler.GetState(player, "FireballCD") then return end
    SpecialMoveHandler.Fireball(player)
    StateHandler.SetState(player, "FireballCD", true, CombatConfig.FireballCD)
end)

game.Players.PlayerRemoving:Connect(function(player)
    hitCounter[player] = nil
    comboTime[player] = nil
end)
