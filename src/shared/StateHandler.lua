-- Shared state tracker for temporary combat flags such as blocking, attacking, stunned, and cooldowns.
-- Works for both players and NPC characters: the first argument may be a Player instance or a
-- character Model, and each function routes to the correct backing table automatically.
local StateHandler = {}

-- stores active state keys for each player
-- example: states[player]["Stunned"] = true
local states = {}
-- stores active state keys for each NPC character model
local characterStates = {}
-- Visual stun representation
local highlighters = {}

-- stores stun expiration data for players/characters currently stunned
local stunTimers = {}

local function isPlayer(obj)
    return obj ~= nil and obj:IsA("Player")
end

-- picks the backing table for a given object (player vs NPC character)
local function getStore(obj)
    if isPlayer(obj) then
        return states
    end
    return characterStates
end

-- resolves the Humanoid to apply walkspeed/stun effects to
local function getHumanoid(obj)
    if isPlayer(obj) then
        return obj.Character and obj.Character:FindFirstChild("Humanoid")
    end
    return obj and obj:FindFirstChild("Humanoid")
end

function StateHandler.ReturnState(obj)
    return getStore(obj)[obj]
end

function StateHandler.GetState(obj, stateKey)
    local store = getStore(obj)
    if store[obj] then
        return store[obj][stateKey]
    end
    return false
end

-- set a generic state on a player or character, optionally clearing it after duration seconds
function StateHandler.SetState(obj, stateKey, value, duration)
    local store = getStore(obj)

    if not store[obj] then
        store[obj] = {}
    end

    -- Store the state value directly on the entry.
    store[obj][stateKey] = value

    -- If a duration is supplied, clear the state automatically after the timer expires.
    if duration and type(duration) == "number" then
        delay(duration, function()
            if store[obj] then
                store[obj][stateKey] = nil

                if next(store[obj]) == nil then
                    store[obj] = nil
                end
            end
        end)
    end
end

function StateHandler.SetStun(obj, value, duration, stunSpeed)
    local humanoid = getHumanoid(obj)
    if not humanoid then return end

    local store = getStore(obj)

    if not store[obj] then
        store[obj] = {}
    end

    if value then
        -- apply stun state and store original speed so it can be restored later
        store[obj]["Stunned"] = true
        if not highlighters[obj] then
            highlighters[obj] = Instance.new("Highlight")
            highlighters[obj].Parent = isPlayer(obj) and obj.Character or obj
            highlighters[obj].FillColor = Color3.fromRGB(255,0,0)
        end

        if not store[obj].OriginalWalkSpeed then
            store[obj].OriginalWalkSpeed = humanoid.WalkSpeed
        end

        humanoid.WalkSpeed = stunSpeed or 0

        local endTime = time() + duration

        if stunTimers[obj] then
            -- extend an existing stun timer if one is active
            stunTimers[obj].EndTime = math.max(stunTimers[obj].EndTime, endTime)
        else
            stunTimers[obj] = {EndTime = endTime}

            coroutine.wrap(function()
                while stunTimers[obj] and time() < stunTimers[obj].EndTime do
                    task.wait(0.1)
                end

                if store[obj] then
                    store[obj]["Stunned"] = nil
                    if highlighters[obj] then
                        highlighters[obj]:Destroy()
                        highlighters[obj] = nil
                    end

                    local currentHumanoid = getHumanoid(obj)
                    if currentHumanoid then
                        currentHumanoid.WalkSpeed = store[obj].OriginalWalkSpeed or 16
                    end

                    store[obj].OriginalWalkSpeed = nil

                    if next(store[obj]) == nil then
                        store[obj] = nil
                    end
                end

                stunTimers[obj] = nil
            end)()
        end
    else
        -- remove stun state immediately and restore walk speed
        store[obj]["Stunned"] = nil
        if highlighters[obj] then
            highlighters[obj]:Destroy()
            highlighters[obj] = nil
        end

        local currentHumanoid = getHumanoid(obj)
        if currentHumanoid then
            currentHumanoid.WalkSpeed = store[obj].OriginalWalkSpeed or 16
        end

        store[obj].OriginalWalkSpeed = nil
        stunTimers[obj] = nil

        if next(store[obj]) == nil then
            store[obj] = nil
        end
    end
end

function StateHandler.RemoveStates(obj, stateKey)
    local store = getStore(obj)
    if not store[obj] then return end

    -- Remove one specific state or clear the entire state table for the object.
    if stateKey then
        store[obj][stateKey] = nil
        if next(store[obj]) == nil then
            store[obj] = nil
        end
    else
        -- remove all states for the object
        store[obj] = nil
    end
end

function StateHandler.ClearAllStates()
    -- remove every stored player/character state and stun timer
    for player in pairs(states) do
        states[player] = nil
    end
    for character in pairs(characterStates) do
        characterStates[character] = nil
    end
    for key in pairs(stunTimers) do
        stunTimers[key] = nil
    end
end

-- cleanup when players leave the game
game.Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    stunTimers[player] = nil
    highlighters[player] = nil
end)

return StateHandler
