local statModule = {}

local stats = {}
local statpoints = {}

local DataStoreService = game:GetService("DataStoreService")
local playerStats = DataStoreService:GetDataStore("playerStats")

function statModule.addStat(player, field, amount)
    if not amount then return end
    amount = math.floor(amount)
    if amount <= 0 then return end
    if not stats[player] or not statpoints[player] then return end

    if stats[player][field] then
        amount = math.min(amount, statpoints[player], 100 - stats[player][field])
        if amount > 0 then
            stats[player][field] += amount
            statpoints[player] -= amount
        end
    end
end

function statModule.resetStats(player)
    if stats[player] then
        if statpoints[player] then
            statpoints[player] += stats[player]["Strength"] + stats[player]["Defense"] + stats[player]["Special"]
            stats[player] = { Strength = 0, Defense = 0, Special = 0 }
        end
    end
end

function statModule.getStatpoints(player)
    if statpoints[player] then
        return statpoints[player]
    end
end

function statModule.getStat(player, field)
    if stats[player] then
        if stats[player][field] then
            return stats[player][field]
        end
    end
end

function statModule.addStatpoints(player, amount)
    if stats[player] then
        if statpoints[player] then
            statpoints[player] += amount
        end
    end
end

function statModule.getStatData(player)
    if stats[player] then
        local stattable = {
            Strength = statModule.getStat(player, "Strength"),
            Defense = statModule.getStat(player, "Defense"),
            Special = statModule.getStat(player, "Special"),
            StatPoints = statModule.getStatpoints(player)
        }
        return stattable
    end
end

function statModule.loadStats(player)
    local success, data = pcall(function()
        return playerStats:GetAsync(tostring(player.UserId))
    end)

    if success then
        if data and data.stats then
            stats[player] = data.stats
            statpoints[player] = data.statpoints or 0
        else
            stats[player] = { Strength = 0, Defense = 0, Special = 0 }
            statpoints[player] = 0
            statModule.addStatpoints(player, 5)
        end
    else
        warn("Failed to load stats: " .. data)
    end
end

function statModule.setStats(player, strength, defense, special)
    if stats[player] then
        stats[player]["Strength"] = strength
        stats[player]["Defense"] = defense
        stats[player]["Special"] = special
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    if not stats[player] or not statpoints[player] then return end
    local storedStats = {stats = stats[player],statpoints = statpoints[player]}
    local success, result = pcall(function()
        playerStats:SetAsync(tostring(player.UserId), storedStats)
    end)
    if success then
        print(player.Name .. "'s Data has been saved")
    else
        warn(player.Name .. "'s  Data has not been saved: " .. result)
    end
    stats[player] = nil
    statpoints[player] = nil
end)


return statModule
