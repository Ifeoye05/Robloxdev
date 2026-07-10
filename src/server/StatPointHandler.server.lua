-- Handles stat point allocation, resets, and stat UI updates for players.
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local statactionEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatActionEvent")
local statupdateEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatUpdateEvent")

-- Load stats before the character spawns so combat/health setup never reads default stats.
game.Players.CharacterAutoLoads = false

statactionEvent.OnServerEvent:Connect(function(player, field, amount, action)
    if action == "Add" then
        if field then
            if amount then
                statModule.addStat(player, field, amount)
                local stattable = statModule.getStatData(player)
                statupdateEvent:FireClient(player, stattable)
            end
        end
    elseif action == "Reset" then
        statModule.resetStats(player)
        local stattable = statModule.getStatData(player)
        statupdateEvent:FireClient(player, stattable)
    elseif action == "AddPoints" then
        if amount then
            statModule.addStatpoints(player, amount)
            local stattable = statModule.getStatData(player)
            statupdateEvent:FireClient(player, stattable)
        end
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    statModule.loadStats(player)
    player:LoadCharacter()
    player.CharacterAdded:Wait()
    local stattable = statModule.getStatData(player)
    statupdateEvent:FireClient(player, stattable)

    player.CharacterAdded:Connect(function()
        local stattable = statModule.getStatData(player)
        statupdateEvent:FireClient(player, stattable)
    end)
end)
