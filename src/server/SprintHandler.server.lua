local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig"))
local StateHandler = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StateHandler"))
local SprintEvent = ReplicatedStorage:WaitForChild("SprintEvent")

SprintEvent.OnServerEvent:Connect(function(player, wantsSprint)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not humanoid then return end
    if StateHandler.GetState(player, "Stunned") then return end
    humanoid.WalkSpeed = wantsSprint and CombatConfig.SprintSpeed or CombatConfig.BaseWalkSpeed
end)
