local ClientState = {}

local equippedSlot = nil

function ClientState.setEquippedSlot(slot)
    equippedSlot = slot
end

function ClientState.getEquippedSlot()
    return equippedSlot
end

return ClientState