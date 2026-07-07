local DamageModule = {}
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))


function DamageModule.dealregularDamage(plr, target)
    local plrStrength = statModule.getStat(plr, "Strength")
    local targetHumanoid = target.Character.Humanoid
    targetHumanoid:TakeDamage(5+(plrStrength*2))
end

function DamageModule.dealspecialDamage(plr, target)
    local plrSpecial = statModule.getStat(plr, "Special")
    local targetHumanoid = target.Character.Humanoid
    targetHumanoid:TakeDamage(10+(plrSpecial*5))
end



return DamageModule