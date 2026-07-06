local statupdateEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatUpdateEvent")

statupdateEvent.OnClientEvent:Connect(function(statdata)
    