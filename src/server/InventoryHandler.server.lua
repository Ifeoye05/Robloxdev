local inventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))
local EquipEvent = game:GetService("ReplicatedStorage"):WaitForChild("EquipEvent")
local InventoryUpdate = game:GetService("ReplicatedStorage"):WaitForChild("InventoryUpdateEvent")
local katana = game:GetService("ServerStorage"):WaitForChild("WoodenKatana")
local equippedWeapons = {}


EquipEvent.OnServerEvent:Connect(function(player, slot)
    local item = inventoryModule.GetSlot(player, slot)
    local inventoryData = inventoryModule.GetInventory(player)
    if item then
        local inventorydataTXT = {}
        for i = 1,5 do
            if inventoryData[i] then
                inventorydataTXT[i] = inventoryData[i].Name
            end
        end
        if equippedWeapons[player] == item then
            equippedWeapons[player].Parent = game.ServerStorage
            equippedWeapons[player] = nil
            InventoryUpdate:FireClient(player, inventorydataTXT)
            return
        end
        if equippedWeapons[player] then
            equippedWeapons[player].Parent = game.ServerStorage
            equippedWeapons[player] = nil
            item.Parent = player.Character
            equippedWeapons[player] = item
        else
            item.Parent = player.Character
            equippedWeapons[player] = item
        end
        InventoryUpdate:FireClient(player, inventorydataTXT)
    else return end
end)

game.Players.PlayerAdded:Connect(function(player)
    local katanatool = katana:Clone()
    player.CharacterAdded:Wait()
    inventoryModule.addItem(player, katanatool, 1)
    local inventoryData = inventoryModule.GetInventory(player)
    local inventorydataTXT = {}
    for i = 1,5 do
        if inventoryData[i] then
            inventorydataTXT[i] = inventoryData[i].Name
        end
    end
    print(inventorydataTXT)
    InventoryUpdate:FireClient(player, inventorydataTXT)
end)