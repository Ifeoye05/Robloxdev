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

local hitAnimIndex = 1
local hitAnims = {CombatConfig.Animations.HitAnim1, CombatConfig.Animations.HitAnim2}

local hitCounter = {}
local comboTime = {}


-- Special moves variables --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")

-- Combat script

PunchEvent.OnServerEvent:Connect(function(player)
    -- Prevent spam attacks while the player is already in an attack state.
    if StateHandler.GetState(player, "Attacking") then return end
    StateHandler.SetState(player, "Attacking", true, CombatConfig.PunchCD)
    local isKatana = InventoryModule.getEquipped(player) ~= nil

    local Character = player.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    local cframe = HumanoidRootPart.CFrame * CFrame.new(0,0,2)
    local size = Vector3.new(4,4,4)
    local range = isKatana and CombatConfig.KatanaRange or CombatConfig.PunchRange
    local direction = cframe.LookVector*range

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
                if isKatana then
                    DamageModule.dealKatanaDamageplayer(player, targetCharacter)
                else
                    DamageModule.dealregularDamageplayer(player, targetCharacter)
                end
                StateHandler.SetStun(targetPlayer, true, CombatConfig.PunchStun)
            else
                -- NPC damage uses the simpler damage path.
                if isKatana then
                    DamageModule.dealKatanaDamagenpc(player, targetCharacter)
                else
                    DamageModule.dealregularDamagenpc(player, targetCharacter)
                end
                StateHandler.SetStun(targetCharacter, true, CombatConfig.PunchStun)
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

-- dash--
local DashEvent = ReplicatedStorage:WaitForChild("DashEvent")

DashEvent.OnServerEvent:Connect(function(player)
    if StateHandler.GetState(player, "Dashing") or StateHandler.GetState(player, "DashCD") then return end
    if StateHandler.GetState(player, "Attacking") or StateHandler.GetState(player, "Blocking") or StateHandler.GetState(player, "Stunned") then return end

    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end

    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude == 0 then
        moveDirection = humanoidRootPart.CFrame.LookVector
    end

    StateHandler.SetState(player, "Dashing", true, CombatConfig.DashDuration)

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = moveDirection * CombatConfig.DashSpeed
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Parent = humanoidRootPart
    game:GetService("Debris"):AddItem(bv, CombatConfig.DashDuration)

    StateHandler.SetState(player, "DashCD", true, CombatConfig.DashCD)
end)

game.Players.PlayerRemoving:Connect(function(player)
    hitCounter[player] = nil
    comboTime[player] = nil
end)
