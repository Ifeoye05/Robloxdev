print("Script Loaded")
-- Regular Combat (M1s, blocking etc) --
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfigModule = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig")
local CombatConfig = require(CombatConfigModule)

local PunchEvent = ReplicatedStorage:WaitForChild("PunchEvent")
local BlockEvent = ReplicatedStorage:WaitForChild("BlockEvent")

local CanPunch = true
local isBlocking = false

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Animationb = Instance.new("Animation")
Animationb.AnimationId = CombatConfig.Animations.Blocking
local blockingAnimation = Humanoid.Animator:LoadAnimation(Animationb)

-- Special Moves --
local FireballEvent = ReplicatedStorage:WaitForChild("FireballEvent")
local canFireball = true

-- Registering Input -- 
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if CanPunch == false then return end
        PunchEvent:FireServer()
        CanPunch = false
        task.wait(CombatConfig.Cooldown)
        CanPunch = true
    end
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = true
        blockingAnimation:Play()
        task.wait(0.1)
        BlockEvent:FireServer(true)
    end

    if input.KeyCode == Enum.KeyCode.Q then
        if canFireball == false then return end
        local Animation = Instance.new("Animation")
        Animation.AnimationId = CombatConfig.Animations.Fireball
        local fireballAnimation = Humanoid.Animator:LoadAnimation(Animation)
        fireballAnimation:Play()
        task.wait(0.61)
        FireballEvent:FireServer()
        canFireball = false
        task.wait(CombatConfig.FireballCD)
        canFireball = true
    end
end)


UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        isBlocking = false
        blockingAnimation:Stop()
        BlockEvent:FireServer(false)
    end
end) 

