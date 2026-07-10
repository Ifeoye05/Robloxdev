-- Displays the death screen and requests a respawn when the server reports the player has died.
local deathEvent = game:GetService("ReplicatedStorage"):WaitForChild("DeathEvent")
local respawnEvent = game:GetService("ReplicatedStorage"):WaitForChild("RespawnEvent")
local player = game:GetService("Players").LocalPlayer
local deathGui = player:WaitForChild("PlayerGui"):WaitForChild("DeathScreen")

deathEvent.OnClientEvent:Connect(function()
    deathGui.Enabled = true
    task.wait(2)
    respawnEvent:FireServer()
    deathGui.Enabled = false
end)
