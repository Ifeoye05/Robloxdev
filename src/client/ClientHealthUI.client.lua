local Players = game:GetService("Players")
local player = Players.LocalPlayer

local healthGui = player:WaitForChild("PlayerGui"):WaitForChild("HealthGui")
local bar = healthGui:WaitForChild("Bar")
local fill = bar:WaitForChild("Frame")
local label = bar:WaitForChild("Label")

local function updateBar(humanoid)
    local pct = humanoid.MaxHealth > 0 and (humanoid.Health / humanoid.MaxHealth) or 0
    fill.Size = UDim2.new(pct, 0, 1, 0)
    label.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    updateBar(humanoid)
    humanoid.HealthChanged:Connect(function()
        updateBar(humanoid)
    end)
    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        updateBar(humanoid)
    end)
end

if player.Character then 
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)