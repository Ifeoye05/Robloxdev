-- Manages player inventory items, equipment swapping, and inventory UI updates.
local inventoryModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("InventoryModule"))
local EquipEvent = game:GetService("ReplicatedStorage"):WaitForChild("EquipEvent")
local InventoryUpdate = game:GetService("ReplicatedStorage"):WaitForChild("InventoryUpdateEvent")
local katana = game:GetService("ServerStorage"):WaitForChild("WoodenKatana")
local equippedWeapons = {}
local equippedSlot = {}


EquipEvent.OnServerEvent:Connect(function(player, slot)
    -- Attempt to equip the item from the requested inventory slot.
    local item = inventoryModule.GetSlot(player, slot)
    local inventoryData = inventoryModule.GetInventory(player)
    if item then
        local inventorydataTXT = {}
        for i = 1,5 do
            if inventoryData[i] then
                inventorydataTXT[i] = inventoryData[i].Name
            end
        end
        -- If the same item is clicked again, unequip it and return it to storage.
        if equippedWeapons[player] == item then
            equippedWeapons[player].Parent = game.ServerStorage
            equippedWeapons[player] = nil
            inventoryModule.setEquipped(player, nil)
            equippedSlot[player] = nil
            InventoryUpdate:FireClient(player, inventorydataTXT, equippedSlot[player])
            return
        end

        -- Swap out the currently equipped weapon before equipping the new one.
        if equippedWeapons[player] then
            equippedWeapons[player].Parent = game.ServerStorage
            equippedWeapons[player] = nil
            item.Parent = player.Character
            equippedWeapons[player] = item
            inventoryModule.setEquipped(player, item)
            equippedSlot[player] = nil
        else
            item.Parent = player.Character
            equippedWeapons[player] = item
            inventoryModule.setEquipped(player, item)
            equippedSlot[player] = slot
        end
        InventoryUpdate:FireClient(player, inventorydataTXT,equippedSlot[player])
    else return end
end)

game.Players.PlayerAdded:Connect(function(player)
    -- Give each new player a starter weapon and send the initial inventory state to their UI.
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
    InventoryUpdate:FireClient(player, inventorydataTXT)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if equippedWeapons[player] then
        equippedWeapons[player]:Destroy()
    end
    equippedWeapons[player] = nil
    equippedSlot[player] = nil
end)