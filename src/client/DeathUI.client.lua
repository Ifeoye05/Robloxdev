local deathEvent = game:GetService("ReplicatedStorage"):WaitForChild("DeathEvent")
local respawnEvent = game:GetService("ReplicatedStorage"):WaitForChild("RespawnEvent")
local plr = game:GetService("Players").LocalPlayer
local deathGui = plr:WaitForChild("PlayerGui"):WaitForChild("DeathScreen")

deathEvent.OnClientEvent:Connect(function()
    deathGui.Enabled = true
    task.wait(2)
    respawnEvent:FireServer()
    deathGui.Enabled = false
end)