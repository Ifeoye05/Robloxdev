-- Shared combat tuning values used by the client and server.
local CombatConfig = {
    Damage = 5,
    PunchCD = 0.2,
    PunchStun = 0.1,
    PunchRange = 2,
    BlockReductionregular = 0, -- Damage is multiplied by the block reduction so 0 means 100% -- 
    BlockReductionspecial = 0.5,
    FireballDamage = 30,
    FireballCD = 2,
    FireballLT = 5,
    FireballSpeed = 2,
    Animations = {
        Fireball = "rbxassetid://98110307361831",
        Blocking = "rbxassetid://70558608395022"
    }
}


return CombatConfig
