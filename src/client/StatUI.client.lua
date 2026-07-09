local statupdateEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatUpdateEvent")
local statactionEvent = game:GetService("ReplicatedStorage"):WaitForChild("StatActionEvent")

local plr = game:GetService("Players").LocalPlayer
local StatValues = plr:WaitForChild("PlayerGui"):WaitForChild("StatGui"):WaitForChild("Mainframe"):WaitForChild("Secondaryframe"):WaitForChild("Statvalues")

local Strength = StatValues:WaitForChild("StrengthValue")
local Defense = StatValues:WaitForChild("DefenseValue")
local Special = StatValues:WaitForChild("SpecialValue")
local Statpoints = StatValues:WaitForChild("StatpointsValue")

local Buttons = plr:WaitForChild("PlayerGui"):WaitForChild("StatGui"):WaitForChild("Mainframe"):WaitForChild("Secondaryframe"):WaitForChild("Buttons")
local Strengthbutton = Buttons:WaitForChild("Strength")
local Defensebutton = Buttons:WaitForChild("Defense")
local Specialbutton = Buttons:WaitForChild("Special")
local Resetbutton = Buttons:WaitForChild("ResetButton")

local InputBox = plr:WaitForChild("PlayerGui"):WaitForChild("StatGui"):WaitForChild("Mainframe"):WaitForChild("Secondaryframe"):WaitForChild("InputBox")

statupdateEvent.OnClientEvent:Connect(function(statdata)
    Strength.Text = statdata.Strength
    Defense.Text = statdata.Defense
    Special.Text = statdata.Special
    Statpoints.Text = statdata.StatPoints

end)

Strengthbutton.MouseButton1Click:Connect(function()
    statactionEvent:FireServer("Strength", tonumber(InputBox.Text), "Add")
end)

Defensebutton.MouseButton1Click:Connect(function()
    statactionEvent:FireServer("Defense", tonumber(InputBox.Text), "Add")
end)

Specialbutton.MouseButton1Click:Connect(function()
    statactionEvent:FireServer("Special", tonumber(InputBox.Text), "Add")
end)

Resetbutton.MouseButton1Click:Connect(function()
    statactionEvent:FireServer(nil, nil, "Reset")
end)

