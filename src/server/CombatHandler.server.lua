local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)
PunchEvent.OnServerEvent:Connect(function(player)
    local Character = player.Character
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Characters = game.Workspace:GetChildren()
    for _, otherCharacter in ipairs(Characters) do
        if Character == otherCharacter then continue end
        local humanoid = otherCharacter:FindFirstChild("Humanoid")
        if humanoid == nil then continue end
        local otherHumanoidRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
        if otherHumanoidRootPart == nil then continue end

        if (HumanoidRootPart.Position - otherHumanoidRootPart.Position).Magnitude <= 7 then
            humanoid:TakeDamage(CombatConfig.Damage)
        end
    end
end)