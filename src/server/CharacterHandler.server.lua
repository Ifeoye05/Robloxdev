local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local deathEvent = game:GetService("ReplicatedStorage"):WaitForChild("DeathEvent")
local respawnEvent = game:GetService("ReplicatedStorage"):WaitForChild("RespawnEvent")

respawnEvent.OnServerEvent:Connect(function(plr)
    plr:LoadCharacter()
end)

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local stats = statModule.getStatData(plr)
        local Humanoid = char.Humanoid
        if stats then
            Humanoid.MaxHealth = (stats.Defense * 2) + 100
            Humanoid.Health = Humanoid.MaxHealth
        end

        char.Humanoid.Died:Connect(function()
            deathEvent:FireClient(plr)
        end)
    end)
end)
