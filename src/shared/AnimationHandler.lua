-- Shared animation helper for loading, tracking, and cleaning up character animations.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local AnimationHandler = {}
AnimationHandler.Anims = {}

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

function AnimationHandler.LoadAnim(char, _type, animId, loop)
    if not char or not _type or not animId then return end

    local animator = getAnimator(char)
    if not animator then return end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    local track = animator:LoadAnimation(animation)
    track.Looped = loop or false 
    if _type == "Idle" then
        track.Priority = Enum.AnimationPriority.Idle
    end
    AnimationHandler.Anims[char] = AnimationHandler.Anims[char] or {}
    AnimationHandler.Anims[char][_type] = AnimationHandler.Anims[char][_type] or {}

    local connections = {}

    table.insert(connections, track.Stopped:Connect(function()
        AnimationHandler.RemoveAnim(char, _type, animId)
    end))

    AnimationHandler.Anims[char][_type][animId] = {
        Track = track,
        Connections = connections,

    }

    track:Play()
    if not loop then 
        Debris:AddItem(track, track.Length +1)
    end
end

function AnimationHandler.GetAnims(char, animType)
    if not AnimationHandler.Anims[char] then return {} end
    if animType then
        return AnimationHandler.Anims[char][animType] or {}
    end
    return AnimationHandler.Anims[char]
end

function AnimationHandler.IsAnim(char, _type, animId)
    local entry = AnimationHandler.Anims[char] and AnimationHandler.Anims[char][_type] and AnimationHandler.Anims[char][_type][animId]
    return entry and entry.Track and entry.Track.IsPlaying or false
end

function AnimationHandler.RemoveAnim(char, _type, animId)
    local animData = AnimationHandler.Anims[char] and AnimationHandler.Anims[char][_type] and AnimationHandler.Anims[char][_type][animId]
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

        AnimationHandler.Anims[char][_type][animId] = nil

        if next(AnimationHandler.Anims[char][_type]) == nil then
            AnimationHandler.Anims[char][_type] = nil
        end
        if next(AnimationHandler.Anims[char]) == nil then
            AnimationHandler.Anims[char] = nil
        end
    end
end

function AnimationHandler.StopAnim(char, _type, animId)
    if not AnimationHandler.Anims[char] then return end

    if _type == "All" then
        for typeKey, anims in pairs(AnimationHandler.Anims[char]) do
            for id in pairs(anims) do
                AnimationHandler.RemoveAnim(char, typeKey, id)
            end
        end
    else
        if animId then
            AnimationHandler.RemoveAnim(char, _type, animId)
        else
            for id in pairs(AnimationHandler.Anims[char][_type] or {}) do
                AnimationHandler.RemoveAnim(char, _type, id)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    local char = player.Character or player:FindFirstChild("Character")
    if AnimationHandler.Anims[char] then
        AnimationHandler.StopAnim(char, "All")
        AnimationHandler.Anims[char] = nil
    end
end)

return AnimationHandler
