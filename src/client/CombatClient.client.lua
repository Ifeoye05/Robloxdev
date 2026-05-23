local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local CanPunch = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if CanPunch == false then return end
        PunchEvent:FireServer()
        CanPunch = false
        task.wait(CombatConfig.Cooldown)
        CanPunch = true
    end
end)