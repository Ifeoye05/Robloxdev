-- Refreshes the inventory UI whenever the server sends updated inventory data.
local InventoryUpdate = game:GetService("ReplicatedStorage"):WaitForChild("InventoryUpdateEvent")
local InventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))
local ClientState = require(script.Parent:WaitForChild("ClientState"))
local animmodule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AnimationHandler"))
local CombatConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CombatConfig"))

local player = game:GetService("Players").LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local PlayerGui = player:WaitForChild("PlayerGui")
local inventoryGui = PlayerGui:WaitForChild("InventoryGui")
local frame = inventoryGui:WaitForChild("InventoryBar")

InventoryUpdate.OnClientEvent:Connect(function(inventorytxt, equippedSlot)
    ClientState.setEquippedSlot(equippedSlot)
    ClientState.setEquippedItem(inventorytxt[equippedSlot] or nil)
    animmodule.StopAnim(Character, "Idle", CombatConfig.Animations.katanaIdle)
    if ClientState.getEquippedItem() then
        animmodule.LoadAnim(Character, "Idle", CombatConfig.Animations.katanaIdle, true)
    end
    for i = 1, 5 do
        local button = frame:FindFirstChild("Slot" .. i)
        local item = inventorytxt[i]
        if not button then return end
        if item then
            button.Text = item .. " " .. i
            if equippedSlot == i then
                button.BackgroundColor3 = Color3.fromRGB(194,194,194)
            else
                button.BackgroundColor3 = Color3.fromRGB(45, 147, 202)
            end
        else
            button.Text = i
        end
    end
end)