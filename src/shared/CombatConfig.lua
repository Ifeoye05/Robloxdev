-- Shared combat tuning values used by the client and server.
local CombatConfig = {
    Damage = 5,
    PunchCD = 0.2,
    PunchStun = 0.1,
    PunchRange = 3.5,
    KatanaRange = 5,
    BlockReductionRegular = 0, -- Damage is multiplied by the block reduction so 0 means 100% --
    BlockReductionSpecial = 0.5,
    FireballDamage = 30,
    FireballCD = 2,
    FireballLT = 5,
    FireballSpeed = 2,
    DashSpeed = 80,
    DashDuration = 0.2,
    DashCD = 1,
    BaseWalkSpeed = 16,
    SprintSpeed = 24,
    BanditMaxHealth = 50,
    BanditRespawnTime = 5,
       Animations = {
        Fireball = "rbxassetid://98110307361831",
        Blocking = "rbxassetid://70558608395022",
        HitAnim1 = "rbxassetid://72140063983832",
        HitAnim2 = "rbxassetid://139973042322592",
        Punch1 = "rbxassetid://78644987297674",
        Punch2 = "rbxassetid://93911078909492",
        Punch3 = "rbxassetid://106926767253705",
        katana1 = "rbxassetid://112865979393596",
        katana2 = "rbxassetid://124608520529972",
        katana3 = "rbxassetid://94640836374147",
        katanaIdle = "rbxassetid://115585931459721",
        KatanaWalk = "rbxassetid://89125747406776",
        KatanaSprint = "rbxassetid://91874068867096",
        dashForward = "rbxassetid://74986573697815",
        dashBack = "rbxassetid://135252025433007",
        dashLeft = "rbxassetid://139355741807291",
        dashRight = "rbxassetid://73788472077037",
        sprintAnim = "rbxassetid://126492339899842"
    },
    Images = {
        itemIcons = {
            WoodenKatana = "rbxassetid://128681387460690",
        },
    }
}



return CombatConfig
