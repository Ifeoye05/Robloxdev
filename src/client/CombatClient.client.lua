local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local CanPunch = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if CanPunch == false then return end
        PunchEvent:FireServer()
        CanPunch = false
        task.wait(0.5)
        CanPunch = true
    end
end)