local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local stats = statModule.getStatData(plr)
        local Humanoid = char.Humanoid
        if stats then
            Humanoid.MaxHealth = (stats.Defense * 2) + 100
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end)