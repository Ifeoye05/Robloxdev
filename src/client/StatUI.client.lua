local statupdateEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatUpdateEvent")
local plr = game:GetService("Players").LocalPlayer
local StatValues = plr:WaitForChild("PlayerGui"):WaitForChild("StatGui"):WaitForChild("Mainframe"):WaitForChild("Secondaryframe"):WaitForChild("Statvalues")
local Strength = StatValues:WaitForChild("StrengthValue")
local Defense = StatValues:WaitForChild("DefenseValue")
local Special = StatValues:WaitForChild("SpecialValue")
local Statpoints = StatValues:WaitForChild("StatpointsValue")

statupdateEvent.OnClientEvent:Connect(function(statdata)
    Strength.Text = statdata.Strength
    Defense.Text = statdata.Defense
    Special.Text = statdata.Special
    Statpoints.Text = statdata.StatPoints

end)