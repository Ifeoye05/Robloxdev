local statModule = {}

local stats = {}
local statpoints = {}

function statModule.addStat(plr, field, amount)
    if stats[plr][field] then
        if amount <= statpoints[plr] then
            stats[plr][field] += amount
            statpoints[plr] -= amount
        end
    end
end

function statModule.resetStats(plr)
    if stats[plr] then
        if statpoints[plr] then
            statpoints[plr] += stats[plr]["Strength"] + stats[plr]["Defense"] + stats[plr]["Special"]
            stats[plr] = { Strength = 0, Defense = 0, Special = 0 }
        end
    end
end

function statModule.getStatpoints(plr)
    if statpoints[plr] then
        return statpoints[plr]
    end
end

function statModule.getStat(plr, field)
    if stats[plr] then
        if stats[plr][field] then
            return stats[plr][field]
        end
    end
end

function statModule.addStatpoints(plr, amount)
    if stats[plr] then
        if statpoints[plr] then
            statpoints[plr] += amount
        end
    end
end

function statModule.getStatData(plr)
    if stats[plr] then
        local stattable = {
            Strength = statModule.getStat(plr, "Strength"),
            Defense = statModule.getStat(plr, "Defense"),
            Special = statModule.getStat(plr, "Special"),
            StatPoints = statModule.getStatpoints(plr)
        }
        return stattable
    end
end

game.Players.PlayerRemoving:Connect(function(plr)
    stats[plr] = nil
    statpoints[plr] = nil
end)

game.Players.PlayerAdded:Connect(function(plr)
    stats[plr] = { Strength = 0, Defense = 0, Special = 0 }
    statpoints[plr] = 0
end)

return statModule