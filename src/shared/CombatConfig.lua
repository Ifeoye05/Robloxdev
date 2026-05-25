local CombatConfig = {
    Damage = 5,
    Cooldown = 0.5,
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
