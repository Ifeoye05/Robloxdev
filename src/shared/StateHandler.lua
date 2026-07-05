local module = {}

-- stores active state keys for each player
-- example: states[player]["Stunned"] = true
local states = {}

-- stores stun expiration data for players currently stunned
local stunTimers = {}

function module.ReturnState(plr)
    return states[plr]
end

function module.GetState(plr, stateKey)
    if states[plr] then
        return states[plr][stateKey]
    end
    return false
end

-- set a generic state on a player, optionally clearing it after duration seconds
function module.SetState(plr, stateKey, value, duration)
    if not states[plr] then 
        states[plr] = {}
    end

    states[plr][stateKey] = value

    if duration and type(duration) == "number" then
        delay(duration, function()
            if states[plr] then
                states[plr][stateKey] = nil

                if next(states[plr]) == nil then
                    states[plr] = nil
                end
            end
        end)
    end
end

function module.SetStun(plr, value, duration, stunSpeed)
    if not plr or not plr.Character or not plr.Character:FindFirstChild("Humanoid") then return end

    local humanoid = plr.Character:FindFirstChild("Humanoid") 

    if not states[plr] then
        states[plr] = {}
    end

    if value then
        -- apply stun state and store original speed so it can be restored later
        states[plr]["Stunned"] = true

        if not states[plr].OriginalWalkSpeed then
            states[plr].OriginalWalkSpeed = humanoid.WalkSpeed
        end

        humanoid.WalkSpeed = stunSpeed or 0

        local endTime = time() + duration

        if stunTimers[plr] then
            -- extend an existing stun timer if one is active
            stunTimers[plr].EndTime = math.max(stunTimers[plr].EndTime, endTime)
        else
            stunTimers[plr] = {EndTime = endTime}

            coroutine.wrap(function()
                while stunTimers[plr] and time() < stunTimers[plr].EndTime do
                    task.wait(0.1)
                end

                if states[plr] then
                    states[plr]["Stunned"] = nil

                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        local currentHumanoid = plr.Character:FindFirstChild("Humanoid")
                        currentHumanoid.WalkSpeed = states[plr].OriginalWalkSpeed or 16
                    end

                    states[plr].OriginalWalkSpeed = nil

                    if next(states[plr]) == nil then
                        states[plr] = nil
                    end
                end

                stunTimers[plr] = nil
            end)()
        end
    else
        -- remove stun state immediately and restore walk speed
        states[plr]["Stunned"] = nil

        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local currentHumanoid = plr.Character:FindFirstChild("Humanoid")
            currentHumanoid.WalkSpeed = states[plr].OriginalWalkSpeed or 16
        end

        states[plr].OriginalWalkSpeed = nil
        stunTimers[plr] = nil

        if next(states[plr]) == nil then
            states[plr] = nil
        end
    end
end




function module.RemoveStates(plr, stateKey)
    if not states[plr] then return end

    if stateKey then
        states[plr][stateKey] = nil
        if next(states[plr]) == nil then
            states[plr] = nil
        end
    else
        -- remove all states for the player
        states[plr] = nil
    end
end

function module.ClearAllStates()
    -- remove every stored player state and stun timer
    for plr in pairs(states) do
        states[plr] = nil
    end
    for plr in pairs(stunTimers) do
        stunTimers[plr] = nil
    end
end

-- cleanup when players leave the game
game.Players.PlayerRemoving:Connect(function(plr)
    states[plr] = nil
    stunTimers[plr] = nil
end)

return module