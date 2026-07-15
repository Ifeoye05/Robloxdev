-- Refreshes the inventory UI whenever the server sends updated inventory data.
local InventoryUpdate = game:GetService("ReplicatedStorage"):WaitForChild("InventoryUpdateEvent")
local InventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))
local ClientState = require(script.Parent:WaitForChild("ClientState"))
local animmodule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AnimationHandler"))
local CombatConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CombatConfig"))

local player = game:GetService("Players").LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerGui = player:WaitForChild("PlayerGui")
local inventoryGui = PlayerGui:WaitForChild("InventoryGui")
local frame = inventoryGui:WaitForChild("InventoryBar")

InventoryUpdate.OnClientEvent:Connect(function(inventorytxt, equippedSlot)
    ClientState.setEquippedSlot(equippedSlot)
    ClientState.setEquippedItem(inventorytxt[equippedSlot] or nil)
    -- Always clear both katana animations first so unequipping cleanly stops
    -- whichever one (idle or walk) happened to be active.
    animmodule.StopAnim(Character, "Idle", CombatConfig.Animations.katanaIdle)
    animmodule.StopAnim(Character, "Walk", CombatConfig.Animations.KatanaWalk)
    if ClientState.getEquippedItem() then
        -- Check actual current movement instead of always defaulting to idle,
        -- so equipping mid-stride starts on the walk animation immediately.
        if Humanoid.MoveDirection.Magnitude > 0.1 then
            animmodule.LoadAnim(Character, "Walk", CombatConfig.Animations.KatanaWalk, true)
        else
            animmodule.LoadAnim(Character, "Idle", CombatConfig.Animations.katanaIdle, true)
        end
    end
    for i = 1, 5 do
        local button = frame:FindFirstChild("Slot" .. i)
        local item = inventorytxt[i]
        if not button then return end
        local icon = button:FindFirstChild("Icon")
        local iconId = item and CombatConfig.Images.itemIcons[item]
        if iconId then
            button.Text = ""
            if icon then
                icon.Image = iconId
                icon.Visible = true
            end
        else
            if icon then
                icon.Visible = false
            end
            if item then
                button.Text = item .. " " .. i
            else
                button.Text = i
            end
        end
        local stroke = button:FindFirstChild("InnerStroke")
        if stroke then
            if equippedSlot == i then
                stroke.Color = Color3.fromRGB(232, 179, 76)
                stroke.Thickness = 3
            else
                stroke.Color = Color3.fromRGB(235, 238, 245)
                stroke.Thickness = 2
            end
        end
    end
end)