-- @vars
local Blips = {}
local Jobs = {
    Go = false,
    Back = false
}

-- @main
CreateThread(function()
    local blip = AddBlipForCoord(-1003.93, -2840.0)
    SetBlipSprite(blip, 90)
    SetBlipDisplay(blip, 6)
    SetBlipScale(0.5)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Trabajo Pilotos')
    while ESX.GetPlayerData() == nil do
        Wait(0)
    end
    PlayerData = ESX.GetPlayerData()
    SpawnNPC('ig_fbisuit_01', Config.NPC)
    while true do
        local msec = 250
        local Player = PlayerPedId()
        local player_Coords = GetEntityCoords(Player)
        local player_Vehicle = GetVehiclePedIsIn(Player)
        if #(player_Coords - vec3(Config.NPC.xyz)) < 3 then
            msec = 0
            if PlayerData.job.name == 'piloto' then
                if Jobs.Go or Jobs.Back then
                    TriggerEvent('ep_notifications:help', "~r~Termina el viaje para tu recompensa")
                else
                    TriggerEvent('ep_notifications:help', "Pulsa ~y~E~w~ para comenzar a trabajar")
                    if IsControlJustPressed(0, 38) then
                        print("hey")
                        ESX.Game.SpawnVehicle('Miljet', vec3(Config.VEHICLE.xyz), Config.VEHICLE.w, function(vehicle) 
                            TaskWarpPedIntoVehicle(Player, vehicle, -1)
                        end)
                        Blips['Destino'] = AddBlipForCoord(Config.SITE)
                        SetBlipRoute(Blips['Destino'], true)
                        SetNewWaypoint(Config.SITE.xy)
                        Jobs.Go = true
                        TriggerEvent('ep_notifications:notify', "Vuela con cuidado")
                    end
                end
            end
        end
        if Jobs.Go then
            if #(player_Coords - Config.SITE) < 50 then
                msec = 0
                DrawMarker(1, vec3(Config.SITE.xy, Config.SITE.z-1), 0, 0, 0, 0, 0, 0, 5.0000, 5.0000, 1.6001,0,255,123, 200, 0, 0, 0, 0)
                if #(player_Coords - Config.SITE) < 5 then
                    TriggerEvent('ep_notifications:help', "Pulsa ~y~E~w~ para soltar a los pasajeros")
                    if IsControlJustPressed(0, 38) then
                        FreezeEntityPosition(player_Vehicle, true)
                        Wait(5000)
                        FreezeEntityPosition(player_Vehicle, false)
                        Jobs.Go = false
                        Jobs.Back = true
                        RemoveBlip(Blips['Destino'])
                        Blips['Destino'] = nil
                        -- new blip
                        Blips['Back'] = AddBlipForCoord(vec3(Config.VEHICLE.xyz))
                        SetBlipRoute(Blips['Back'], true)
                        SetNewWaypoint(Config.VEHICLE.xy)
                    end
                end
            end
        end
        if Jobs.Back then
            if #(player_Coords - vec3(Config.VEHICLE.xyz)) < 50 then
                msec = 0
                DrawMarker(1, vec3(Config.VEHICLE.xy, Config.VEHICLE.z-1), 0, 0, 0, 0, 0, 0, 5.0000, 5.0000, 1.6001,0,255,123, 200, 0, 0, 0, 0)
                if #(player_Coords - vec3(Config.VEHICLE.xyz)) < 5 then
                    TriggerEvent('ep_notifications:help', "Presiona ~y~E~s~ para guardar el avion")
                    if IsControlJustPressed(0, 38) then
                        DeleteVehicle(player_Vehicle)
                        Jobs.Back = false
                        RemoveBlip(Blips['Back'])
                        Blips['Back'] = nil
                        TriggerServerEvent('trabajo_piloto:pagar')
                    end
                end
            end
        end
        Wait(msec)
    end
end)

-- @events

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer 
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job 
end)

-- @funcs
function SpawnNPC(modelo, x,y,z,h)
    hash = GetHashKey(modelo)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end
    crearNPC = CreatePed(5, hash, x,y,z,h, false, true)
    FreezeEntityPosition(crearNPC, true)
    SetEntityInvincible(crearNPC, true)
    SetBlockingOfNonTemporaryEvents(crearNPC, true)
    TaskStartScenarioInPlace(crearNPC, "WORLD_HUMAN_AA_COFFEE", 0, false)
end