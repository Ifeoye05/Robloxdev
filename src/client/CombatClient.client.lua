-- Handles the local player's combat inputs.
-- This script translates mouse and keyboard actions into server requests for attacks, blocking, special moves, and equipment changes.
local animmodule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AnimationHandler"))
local RunService = game:GetService("RunService")
local StateHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))
local ClientState = require(script.Parent:WaitForChild("ClientState"))

-- Regular Combat (M1s, blocking etc) --
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)

local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")
local EquipEvent = ReplicatedStorage:WaitForChild("EquipEvent")
local statactionEvent = ReplicatedStorage:WaitForChild("StatActionEvent")

local player = game:GetService("Players").LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Preload every combat animation so the first play of each one doesn't
-- lag/skip while Roblox fetches its keyframe data from the CDN.
local ContentProvider = game:GetService("ContentProvider")
local preloadInstances = {}
for _, animId in pairs(CombatConfig.Animations) do
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    table.insert(preloadInstances, anim)
end

-- Also preload the default character animations (walk, run, jump, etc.) from
-- the built-in Animate script, otherwise the first walk cycle after we hand
-- control back to it (e.g. after a custom idle pose stops) can glide/skip.
local animateScript = Character:FindFirstChild("Animate")
if animateScript then
    for _, desc in ipairs(animateScript:GetDescendants()) do
        if desc:IsA("Animation") then
            table.insert(preloadInstances, desc)
        end
    end
end

ContentProvider:PreloadAsync(preloadInstances)

local slotKeys = {
    [Enum.KeyCode.One] = 1,
    [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4,
    [Enum.KeyCode.Five] = 5,
}


-- Punch combo animations --
local punchAnims = {CombatConfig.Animations.Punch1, CombatConfig.Animations.Punch2, CombatConfig.Animations.Punch3}
local punchAnimIndex = 1

--Katana combo animations --
local katanaAnims = {CombatConfig.Animations.katana1, CombatConfig.Animations.katana2, CombatConfig.Animations.katana3}
local katanaAnimIndex = 1

-- Blocking vfx --
local BlockvfxTemplate = ReplicatedStorage:WaitForChild("BlockvfxTemplate")
local blockVfx = nil

-- lock on --
local lockedOn = false
local lockOnConnection = nil

-- Special Moves --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")

-- dash move --
local DashEvent = ReplicatedStorage:WaitForChild("DashEvent")

-- Sprint move --
local SprintEvent = ReplicatedStorage:WaitForChild("SprintEvent")

-- Katana walk/idle swap while equipped, driven directly by movement key
-- presses (same play-on-down/stop-on-up pattern as Sprint above) instead of
-- polling movement every frame.
local heldMovementKeys = {}
local heldMovementCount = 0
local movementKeySet = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
}

-- Registering Input --
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if StateHandler.GetState(player, "Attacking") or StateHandler.GetState(player, "Blocking") or StateHandler.GetState(player, "Stunned") then return end
        PunchEvent:FireServer()
        StateHandler.SetState(player, "Attacking", true, 0.2)
        if ClientState.getEquippedItem() then
            animmodule.LoadAnim(Character, "Punch", katanaAnims[katanaAnimIndex])
            katanaAnimIndex = katanaAnimIndex % 3 + 1
        else
            animmodule.LoadAnim(Character, "Punch", punchAnims[punchAnimIndex])
            punchAnimIndex = punchAnimIndex % 3 + 1
        end
    end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        SprintEvent:FireServer(true)
        if ClientState.getEquippedItem() then
            animmodule.LoadAnim(Character, "Sprint", CombatConfig.Animations.KatanaSprint, true)
        else
            animmodule.LoadAnim(Character, "Sprint", CombatConfig.Animations.sprintAnim, true)
        end
    end

    if movementKeySet[input.KeyCode] and not heldMovementKeys[input.KeyCode] then
        heldMovementKeys[input.KeyCode] = true
        heldMovementCount += 1
        if heldMovementCount == 1 and ClientState.getEquippedItem() then
            animmodule.StopAnim(Character, "Idle", CombatConfig.Animations.katanaIdle)
            animmodule.LoadAnim(Character, "Walk", CombatConfig.Animations.KatanaWalk, true)
        end
    end

      if input.KeyCode == Enum.KeyCode.F then
        if StateHandler.GetState(player, "Stunned") or StateHandler.GetState(player, "Attacking") then return end
        BlockEvent:FireServer(true)
        StateHandler.SetState(player, "Blocking", true)
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local block = BlockvfxTemplate:Clone()
        block.CFrame = HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
        block.Parent = Character
        local weld = Instance.new("WeldConstraint")
        weld.Parent = block
        weld.Part0 = block
        weld.Part1 = HumanoidRootPart
        blockVfx = block
        blockVfx.Attachment.Shield:Emit(1)
        animmodule.LoadAnim(Character, "Block", CombatConfig.Animations.Blocking)
    end

    if input.KeyCode == Enum.KeyCode.LeftAlt then
        lockedOn = not lockedOn
        Humanoid.AutoRotate = not lockedOn
        if lockedOn then
            UserInputService.MouseIcon = "rbxassetid://72726323621123"
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            lockOnConnection = RunService.RenderStepped:Connect(function()
                local camera = workspace.CurrentCamera
                local lookVector = camera.CFrame.LookVector
                lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
                local rootPart = Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                end
            end)
        else
            UserInputService.MouseIcon = ""
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            if lockOnConnection then
                lockOnConnection:Disconnect()
                lockOnConnection = nil
            end
        end
    end

    if input.KeyCode == Enum.KeyCode.Q then
        if StateHandler.GetState(player, "Attacking") or StateHandler.GetState(player, "Blocking") or StateHandler.GetState(player, "Stunned") or StateHandler.GetState(player, "Dashing") or StateHandler.GetState(player, "DashCD") then return end
        local dashAnim = CombatConfig.Animations.dashForward
        if lockedOn then
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dashAnim = CombatConfig.Animations.dashBack
        elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dashAnim = CombatConfig.Animations.dashLeft
        elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dashAnim = CombatConfig.Animations.dashRight 
            elseif UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dashAnim = CombatConfig.Animations.dashForward
            end
        end
        DashEvent:FireServer()
        StateHandler.SetState(player, "Dashing", true, CombatConfig.DashDuration)
        StateHandler.SetState(player, "DashCD", true, CombatConfig.DashCD)
        animmodule.LoadAnim(Character, "Dash", dashAnim)
    end

    if input.KeyCode == Enum.KeyCode.M then
        statactionEvent:FireServer(nil, 10, "AddPoints")
    end

    if input.KeyCode == Enum.KeyCode.Z then
        if ClientState.getEquippedSlot() then return end
        if StateHandler.GetState(player, "Attacking") or StateHandler.GetState(player, "FireballCD") or StateHandler.GetState(player, "Blocking") or StateHandler.GetState(player, "Stunned") then return end
                StateHandler.SetState(player, "Attacking", true)
        animmodule.LoadAnim(Character, "Fireball", CombatConfig.Animations.Fireball)
        task.wait(0.61)
        FireballEvent:FireServer()
        StateHandler.RemoveStates(player, "Attacking")
        StateHandler.SetState(player, "FireballCD", true, CombatConfig.FireballCD)
    end

    local slot = slotKeys[input.KeyCode]
    if slot then
        EquipEvent:FireServer(slot)
    end
end)


UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        StateHandler.RemoveStates(player, "Blocking")
        animmodule.StopAnim(Character, "Block", CombatConfig.Animations.Blocking)
        BlockEvent:FireServer(false)
        if blockVfx then
            game:GetService("Debris"):AddItem(blockVfx, 0)
        end
    end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        SprintEvent:FireServer(false)
        if ClientState.getEquippedItem() then
            animmodule.StopAnim(Character, "Sprint", CombatConfig.Animations.KatanaSprint)
        else
            animmodule.StopAnim(Character, "Sprint", CombatConfig.Animations.sprintAnim)
        end
    end

    if movementKeySet[input.KeyCode] and heldMovementKeys[input.KeyCode] then
        heldMovementKeys[input.KeyCode] = nil
        heldMovementCount -= 1
        if heldMovementCount == 0 and ClientState.getEquippedItem() then
            animmodule.StopAnim(Character, "Walk", CombatConfig.Animations.KatanaWalk)
            animmodule.LoadAnim(Character, "Idle", CombatConfig.Animations.katanaIdle, true)
        end
    end
end)
