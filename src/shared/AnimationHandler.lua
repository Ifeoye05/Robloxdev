local combatModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CombatConfig"))

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local module = {}
module.Anims = {}

local function getAnimator(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Name = "Animator"
        animator.Parent = humanoid
    end
    return animator 
end

function module.LoadAnim(char, _type, animId)
    if not char or not _type or not animId then return end

    local animator = getAnimator(char)
    if not animator then return end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    local track = animator:LoadAnimation(animation)

    module.Anims[char] = module.Anims[char] or {}
    module.Anims[char][_type] = module.Anims[char][_type] or {}

    local connections = {}

    table.insert(connections, track.Stopped:Connect(function()
        module.RemoveAnim(char, _type, animId)
    end))

    module.Anims[char][_type][animId] = {
        Track = track,
        Connections = connections,

    }

    track:Play()
    Debris:AddItem(track, track.Length + 1)
end

function module.GetAnims(char, animType)
    if not module.Anims[char] then return {} end
    if animType then
        return module.Anims[char][animType] or {}
    end
    return module.Anims[char]
end

function module.IsAnim(char, _type, animId)
    local entry = module.Anims[char] and module.Anims[char][_type] and module.Anims[char][_type][animId]
    return entry and entry.Track and entry.Track.IsPlaying or false
end

function module.RemoveAnim(char, _type, animId)
    local animData = module.Anims[char] and module.Anims[char][_type] and module.Anims[char][_type][animId]
    if animData then
        if animData.Track then
            animData.Track:Stop()
            animData.Track:Destroy()
        end

        if animData.Connections then
            for _, conn in ipairs(animData.Connections) do
                if conn.Connected then
                    conn:Disconnect()
                end
            end
        end

        module.Anims[char][_type][animId] = nil

        if next(module.Anims[char][_type]) == nil then
            module.Anims[char][_type] = nil
        end
        if next(module.Anims[char]) == nil then
            module.Anims[char] = nil
        end
    end
end

function module.StopAnim(char, _type, animId)
    if not module.Anims[char] then return end

    if _type == "All" then
        for typeKey, anims in pairs(module.Anims[char]) do
            for id in pairs(anims) do
                module.RemoveAnim(char, typeKey, id)
            end
        end
    else
        if animId then
            module.RemoveAnim(char, _type, animId)
        else
            for id in pairs(module.Anims[char][_type] or {}) do
                module.RemoveAnim(char, _type, id)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    local char = player.Character or player:FindFirstChild("Character")
    if module.Anims[char] then
        module.StopAnim(char, "All")
        module.Anims[char] = nil
    end
end)

return module