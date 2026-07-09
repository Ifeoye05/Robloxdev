local statModule = {}

local stats = {}
local statpoints = {}

local DataStoreService = game:GetService("DataStoreService")
local playerStats = DataStoreService:GetDataStore("playerStats")

function statModule.addStat(plr, field, amount)
    if not amount then return end
    amount = math.floor(amount)
    if amount <= 0 then return end

    if stats[plr][field] then
        if amount <= statpoints[plr] then
            if stats[plr][field] + amount <= 100 then
                stats[plr][field] += amount
                statpoints[plr] -= amount
            end
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

function statModule.loadStats(plr)
    local success, data = pcall(function()
        return playerStats:GetAsync(tostring(plr.UserId))
    end)

    if success then
        if data and data.stats then
            stats[plr] = data.stats
            statpoints[plr] = data.statpoints or 0
        else
            stats[plr] = { Strength = 0, Defense = 0, Special = 0 }
            statpoints[plr] = 0
            statModule.addStatpoints(plr, 5)
        end
    else
        warn("Failed to load stats: " .. data)
    end
end

function statModule.setStats(plr, strength, defense, special)
    if stats[plr] then
        stats[plr]["Strength"] = strength
        stats[plr]["Defense"] = defense
        stats[plr]["Special"] = special
    end
end

game.Players.PlayerRemoving:Connect(function(plr)
    if not stats[plr] or not statpoints[plr] then return end
    local storedStats = {stats = stats[plr],statpoints = statpoints[plr]}
    local success, result = pcall(function()
        playerStats:SetAsync(tostring(plr.UserId), storedStats)
    end)
    if success then
        print(plr.Name .. "'s Data has been saved")
    else
        warn(plr.Name .. "'s  Data has not been saved: " .. result)
    end
    stats[plr] = nil
    statpoints[plr] = nil
end)


return statModule