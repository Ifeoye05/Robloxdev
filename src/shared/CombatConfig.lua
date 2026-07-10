-- Shared combat tuning values used by the client and server.
local CombatConfig = {
    Damage = 5,
    PunchCD = 0.2,
    PunchStun = 0.1,
    PunchRange = 3.5,
    BlockReductionRegular = 0, -- Damage is multiplied by the block reduction so 0 means 100% --
    BlockReductionSpecial = 0.5,
    FireballDamage = 30,
    FireballCD = 2,
    FireballLT = 5,
    FireballSpeed = 2,
    Animations = {
        Fireball = "rbxassetid://98110307361831",
        Blocking = "rbxassetid://70558608395022",
        HitAnim1 = "rbxassetid://72140063983832",
        HitAnim2 = "rbxassetid://139973042322592",
        Punch1 = "rbxassetid://78644987297674",
        Punch2 = "rbxassetid://139966315414353",
        Punch3 = "rbxassetid://106926767253705"
    }
}


return CombatConfig
