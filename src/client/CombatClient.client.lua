-- Handles the local player's combat inputs.
-- This script translates mouse and keyboard actions into server requests for attacks, blocking, special moves, and equipment changes.
local animmodule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AnimationHandler"))
local module = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StateHandler"))
local ClientState = require(script.Parent:WaitForChild("ClientState"))

-- Regular Combat (M1s, blocking etc) --
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)

local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")
local EquipEvent = ReplicatedStorage:WaitForChild("EquipEvent")
local statactionevent = ReplicatedStorage:WaitForChild("StatActionEvent")

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local slotKeys = {
    [Enum.KeyCode.One] = 1,
    [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4,
    [Enum.KeyCode.Five] = 5,
}


-- Blocking vfx --
local BlockvfxTemplate = ReplicatedStorage:WaitForChild("BlockvfxTemplate")
local blockVfx = nil

-- Special Moves --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")

-- Registering Input -- 
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if ClientState.getEquippedSlot() then return end
        if module.GetState(Player, "Attacking") or module.GetState(Player, "Blocking") or module.GetState(Player, "Stunned") then return end
        PunchEvent:FireServer()
        module.SetState(Player, "Attacking", true, 0.2)
    end

    if input.KeyCode == Enum.KeyCode.F then
        if module.GetState(Player, "Stunned") or module.GetState(Player, "Attacking") then return end
        BlockEvent:FireServer(true)
        module.SetState(Player, "Blocking", true)
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

    if input.KeyCode == Enum.KeyCode.M then
        statactionevent:FireServer(nil, 10, "AddPoints")
    end

    if input.KeyCode == Enum.KeyCode.Q then
        if ClientState.getEquippedSlot() then return end
        if module.GetState(Player, "Attacking") or module.GetState(Player, "FireballCD") or module.GetState(Player, "Blocking") or module.GetState(Player, "Stunned") then return end
        module.SetState(Player, "Attacking", true)
        animmodule.LoadAnim(Character, "Fireball", CombatConfig.Animations.Fireball)
        task.wait(0.61)
        FireballEvent:FireServer()
        module.RemoveStates(Player, "Attacking")
        module.SetState(Player, "FireballCD", true, CombatConfig.FireballCD)
    end

    local slot = slotKeys[input.KeyCode]
    if slot then
        EquipEvent:FireServer(slot)
    end
end)


UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        module.RemoveStates(Player, "Blocking")
        animmodule.StopAnim(Character, "Block", CombatConfig.Animations.Blocking)
        BlockEvent:FireServer(false)
        if blockVfx then
            game:GetService("Debris"):AddItem(blockVfx, 0)
        end
    end
end) 

