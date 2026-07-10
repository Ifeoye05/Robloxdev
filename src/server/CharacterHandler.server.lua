-- Handles character spawning, stat-based health setup, and death/respawn events.
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))
local deathEvent = game:GetService("ReplicatedStorage"):WaitForChild("DeathEvent")
local respawnEvent = game:GetService("ReplicatedStorage"):WaitForChild("RespawnEvent")

respawnEvent.OnServerEvent:Connect(function(player)
    player:LoadCharacter()
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local stats = statModule.getStatData(player)
        local Humanoid = character.Humanoid
        if stats then
            Humanoid.MaxHealth = (stats.Defense * 2) + 100
            Humanoid.Health = Humanoid.MaxHealth
        end

        character.Humanoid.Died:Connect(function()
            deathEvent:FireClient(player)
        end)
    end)
end)
