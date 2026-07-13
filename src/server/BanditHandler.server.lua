local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig"))

local banditTemplate = ServerStorage:WaitForChild("Bandit")
local spawnPoint = Workspace:WaitForChild("BanditSpawn")

local function updateHealthBar(bandit, humanoid)
    local fill = bandit.Head.HealthBillboard.Bar.Fill
    local pct = humanoid.MaxHealth > 0 and (humanoid.Health / humanoid.MaxHealth) or 0
    fill.Size = UDim2.new(pct, 0, 1, 0)
end

local function spawnBandit()
    local bandit = banditTemplate:Clone()
    local _, size = bandit:GetBoundingBox()
    local spawnCFrame = spawnPoint.CFrame * CFrame.new(0, (spawnPoint.Size.Y / 2) + (size.Y / 2), 0)
    bandit:PivotTo(spawnCFrame)
    bandit.Parent = Workspace

    local humanoid = bandit:WaitForChild("Humanoid")
    humanoid.MaxHealth = CombatConfig.BanditMaxHealth
    humanoid.Health = humanoid.MaxHealth
    updateHealthBar(bandit, humanoid)

    humanoid.HealthChanged:Connect(function()
        updateHealthBar(bandit, humanoid)
    end)

    humanoid.Died:Connect(function()
        bandit:Destroy()
        task.wait(CombatConfig.BanditRespawnTime)
        spawnBandit()
    end)
end

spawnBandit()

