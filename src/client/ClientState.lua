local ClientState = {}

local equippedSlot = nil
local equippedItemName = nil
function ClientState.setEquippedSlot(slot)
    equippedSlot = slot
end

function ClientState.getEquippedSlot()
    return equippedSlot
end

function ClientState.setEquippedItem(name)
    equippedItemName = name
end

function ClientState.getEquippedItem()
    return equippedItemName
end

return ClientState