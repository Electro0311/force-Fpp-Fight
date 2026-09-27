Config = {}

-- true: only the driver is forced into first person when shooting. false: every occupant is.
Config.DriverOnly = false

-- How long (ms) after the player stops aiming/shooting before their old camera view comes back.
-- Stops the camera flicking back and forth between shots.
Config.RestoreDelay = 500

-- Vehicle classes where shooting does NOT force first person.
-- 8 = Motorcycles, 13 = Cycles, 14 = Boats, 15 = Helicopters, 16 = Planes, 21 = Trains
-- Full list: https://docs.fivem.net/natives/?_0x29439776AAA00A62
Config.ExemptClasses = {
    -- 8,
    -- 15,
    -- 16,
}
