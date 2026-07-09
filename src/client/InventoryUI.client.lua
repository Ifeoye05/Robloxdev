local InventoryUpdate = game:GetService("ReplicatedStorage"):WaitForChild("InventoryUpdateEvent")
local InventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))

local player = game:GetService("Players").LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local inventoryGui = PlayerGui:WaitForChild("InventoryGui")
local frame = inventoryGui:WaitForChild("InventoryBar")

InventoryUpdate.OnClientEvent:Connect(function(inventorytxt, equippedSlot)
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
        print(item)
    end
end)