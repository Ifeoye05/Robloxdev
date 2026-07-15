-- Adds hover/press scale feedback to the game's interactive UI buttons.
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local HOVER_SCALE = 1.08
local PRESS_SCALE = 0.92
local NORMAL_SCALE = 1

local hoverTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local pressTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setupButtonEffect(button)
    if not button or not button:IsA("GuiButton") then return end
    if button:GetAttribute("_hoverEffectSetup") then return end
    button:SetAttribute("_hoverEffectSetup", true)

    local scale = button:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Parent = button
    end

    local isHovering = false

    local function tweenTo(target, info)
        TweenService:Create(scale, info, {Scale = target}):Play()
    end

    button.MouseEnter:Connect(function()
        isHovering = true
        tweenTo(HOVER_SCALE, hoverTweenInfo)
    end)

    button.MouseLeave:Connect(function()
        isHovering = false
        tweenTo(NORMAL_SCALE, hoverTweenInfo)
    end)

    button.MouseButton1Down:Connect(function()
        tweenTo(PRESS_SCALE, pressTweenInfo)
    end)

    button.MouseButton1Up:Connect(function()
        tweenTo(isHovering and HOVER_SCALE or NORMAL_SCALE, hoverTweenInfo)
    end)
end

local inventoryGui = PlayerGui:WaitForChild("InventoryGui")
local bar = inventoryGui:WaitForChild("InventoryBar")
for i = 1, 5 do
    local slot = bar:FindFirstChild("Slot" .. i)
    if slot then
        setupButtonEffect(slot)
    end
end

local statGui = PlayerGui:WaitForChild("StatGui")
setupButtonEffect(statGui:WaitForChild("StatsButton"))

local mainframe = statGui:WaitForChild("Mainframe")
local secondaryframe = mainframe:WaitForChild("Secondaryframe")
local buttonsFolder = secondaryframe:FindFirstChild("Buttons")
if buttonsFolder then
    for _, btn in ipairs(buttonsFolder:GetChildren()) do
        if btn:IsA("GuiButton") then
            setupButtonEffect(btn)
        end
    end
end
