local CombatConfig = {
    Damage = 5,
    PunchCD = 0.2,
    PunchStun = 0.1,
    BlockReduction = 0, -- Damage is multiplied by the block reduction so 0 means 1 -- 
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
