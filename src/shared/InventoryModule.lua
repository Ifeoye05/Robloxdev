-- Stores each player's temporary inventory data and exposes helpers for adding, removing, and reading items.
local playerInventories = {}
local inventory = {}
local equippedItems = {}

function inventory.addItem(player, item, slot)
    if  not playerInventories[player] then
        playerInventories[player] = {}
    end
    if slot then
        if slot >= 1 and slot <= 5 then
            if playerInventories[player][slot] == nil then
                playerInventories[player][slot] = item
            else return end
        end
    else
        for i = 1, 5 do
            if playerInventories[player][i] == nil then
                playerInventories[player][i] = item
                return
            end
        end
    end
end

function inventory.RemoveItem(player, slot)
    if playerInventories[player] then
        if slot >= 1 and slot <= 5 then
            if playerInventories[player][slot] then
                playerInventories[player][slot] = nil
            end
        end
    end   
end

function inventory.GetSlot(player, slot)
    if not playerInventories[player] or not playerInventories[player][slot] then return end
    return playerInventories[player][slot]
end

function inventory.GetInventory(player)
    if playerInventories[player] then
        return playerInventories[player]
    end
end

function inventory.getEquipped(player)
    return equippedItems[player]
end

function inventory.setEquipped(player, item)
    equippedItems[player] = item
end

game.Players.PlayerRemoving:Connect(function(player)
    playerInventories[player] = nil
    equippedItems[player] = nil
end)

return inventory