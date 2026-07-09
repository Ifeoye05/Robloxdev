-- Handles stat point allocation, resets, and stat UI updates for players.
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local statactionEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatActionEvent")
local statupdateEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatUpdateEvent")

statactionEvent.OnServerEvent:Connect(function(plr, field, amount, action)
    if action == "Add" then
        if field then
            if amount then
                statModule.addStat(plr, field, amount)
                local stattable = statModule.getStatData(plr)
                statupdateEvent:FireClient(plr, stattable)
            end
        end
    elseif action == "Reset" then
        statModule.resetStats(plr)
        local stattable = statModule.getStatData(plr)
        statupdateEvent:FireClient(plr, stattable)
    elseif action == "AddPoints" then
        if amount then
            statModule.addStatpoints(plr, amount)
            local stattable = statModule.getStatData(plr)
            statupdateEvent:FireClient(plr, stattable)
        end
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    statModule.loadStats(plr)
    local stattable = statModule.getStatData(plr)
    statupdateEvent:FireClient(plr, stattable)
    
    plr.CharacterAdded:Connect(function()
        local stattable = statModule.getStatData(plr)
        statupdateEvent:FireClient(plr, stattable)
    end)
end)