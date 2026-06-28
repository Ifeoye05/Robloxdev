local inventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))
local EquipEvent = game:GetService("ReplicatedStorage"):WaitForChild("EquipEvent")
local equippedWeapons = {}


EquipEvent.OnServerEvent:Connect(function(player, slot)
    local item = inventoryModule.GetSlot(player, slot)
    if item then
        if equippedWeapons[player] then
            equippedWeapons[player].Parent = game.ServerStorage
            equippedWeapons[player] = nil
            item.Parent = player.Character
            equippedWeapons[player] = item
        else
            item.Parent = player.Character
            equippedWeapons[player] = item
        end
    else return end
end)