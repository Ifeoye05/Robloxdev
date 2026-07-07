local DamageModule = {}
local statModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("StatModule"))


function DamageModule.dealregularDamage(plr, targethumanoid)
    local plrStrength = statModule.getStat(plr, "Strength")
    targethumanoid:TakeDamage(5+(plrStrength*2))
end

function DamageModule.dealspecialDamage(plr, targethumanoid)
    local plrSpecial = statModule.getStat(plr, "Special")
    targethumanoid:TakeDamage(10+(plrSpecial*5))
end



return DamageModule