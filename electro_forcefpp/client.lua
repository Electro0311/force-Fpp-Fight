local FIRST_PERSON = 4

local exempt = {}
for _, class in ipairs(Config.ExemptClasses) do
    exempt[class] = true
end

-- Set while we hold the player in first person: the camera context we changed and the view mode it had before.
local forced

local function shouldForce(ped, vehicle)
    if exempt[GetVehicleClass(vehicle)] then return false end
    if Config.DriverOnly and GetPedInVehicleSeat(vehicle, -1) ~= ped then return false end
    return true
end

local function isShooting(ped)
    if IsPedDoingDriveby(ped) or IsPedShooting(ped) then return true end
    -- Catch the aim/fire press on the first frame, before the drive-by task starts.
    return IsControlPressed(0, 68)  -- INPUT_VEH_AIM
        or IsControlPressed(0, 69)  -- INPUT_VEH_ATTACK
        or IsControlPressed(0, 91)  -- INPUT_VEH_PASSENGER_AIM
        or IsControlPressed(0, 92)  -- INPUT_VEH_PASSENGER_ATTACK
end

local function restore()
    if not forced then return end
    SetCamViewModeForContext(forced.context, forced.mode)
    forced = nil
end

CreateThread(function()
    local lastShot = 0

    while true do
        local ped = PlayerPedId()
        local vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0

        -- IsPedArmed flag 4 = firearms only (no melee or throwables).
        if vehicle ~= 0 and IsPedArmed(ped, 4) and shouldForce(ped, vehicle) then
            if isShooting(ped) then
                lastShot = GetGameTimer()

                if not forced then
                    -- Cars, bikes, boats, helis and planes each have their own view-mode context.
                    local context = GetCamActiveViewModeContext()
                    forced = { context = context, mode = GetCamViewModeForContext(context) }
                end

                if GetCamViewModeForContext(forced.context) ~= FIRST_PERSON then
                    SetCamViewModeForContext(forced.context, FIRST_PERSON)
                end
            elseif forced and GetGameTimer() - lastShot > Config.RestoreDelay then
                restore()
            end

            if forced then
                DisableControlAction(0, 0, true)  -- INPUT_NEXT_CAMERA (V)
                DisableControlAction(0, 80, true) -- INPUT_VEH_CIN_CAM (R / cinematic cam)
            end

            Wait(0)
        else
            restore()
            Wait(250)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    restore()
end)
