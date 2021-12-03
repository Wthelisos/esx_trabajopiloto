local job = false 
local job2 = false 
local v2 = vector2(-1003.93, -2840.0)
--
--
--
local blip = AddBlipForCoord(v2.x, v2.y)
SetBlipSprite(blip, 90)
SetBlipDisplay(blip, 6)
SetBlipScale(0.5)
BeginTextCommandSetBlipName('STRING')
AddTextComponentString('Trabajo Pilotos')

ESX = nil 
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getShareObject', function(obj) ESX = obj end)
        Citizen.Wait(0)

    end
end)
 
Citizen.CreateThread(function()
    SpawnNPC('ig_fbisuit_01', vector4(-1003.93, -2840.0, 12.9, 228.29))
    while true do 
        local _sleep = 1000
        local _char = PlayerPedId()
        local _charPos = GetEntityCoords(_char)
        if #(_charPos - vector3(-1003.93, -2840.0, 13.9)) < 2 then
            _sleep = 0
            if job == true or job2 == true then 
                Create3D(vector3(-1003.93, -2840.0, 14.9), '~r~Vuelva al Avion')
            else
                Create3D(vector3(-1003.93, -2840.0, 14.9), 'Pulsa ~y~E~w~ para comenzar a trabajar')
                if (IsControlPressed(0, 38)) then
                    ESX.Game.SpawnVehicle('miljet', vector3(-976.3, -2998.2, 13.9), 52.79, function(vehicle)
                        exports['LegacyFuel']:SetFuel(vehicle, 100) 
                        TaskWarpPedIntoVehicle(_char, vehicle, -1)
                    end)
                    blip = AddBlipForCoord(vector3(1626.6, 3231.6, 39.7))
                    SetBlipRoute(blip, true)
                    job = true
                end
            end
        end
        if job == true then 
            if #(_charPos - vector3(1626.6, 3231.6, 39.7)) < 2 then
                _sleep = 0    
                Create3D(vector3(1626.6, 3231.6, 39.7), 'Pulsa ~y~E~w~ para soltar a los pasajeros')
                if IsControlJustProssed(0, 38) then
                    RemoveBlip(blip)
                    SetBlipRoute(blip, false)
                    blip2 = AddBlipForCoord(vector3(-976.3, -2998.2, 13.9))
                    SetBlipRoute(blip2, true)
                   job = false
                   job2 = true
                end
            end
        end  
        if job2 == true then
            if #(_charPos - vector3(-976.3, -2998.2, 13.9)) < 2 then
                _sleep = 0    
                Create3D(vector3(-976.3, -2998.2, 13.9), 'Pulsa ~y~E~w~ entregar el avion')
                if IsControlJustProssed(0, 38) then
                    DeleteVehicle(GetVehiclePedIsIn(_char))
                    RemoveBlip(blip2)
                    SetBlipRoute(blip2, false)
                    TriggerServerEvent('trabajo_piloto:pagar')
                   job = false
                   job2 = false
                end
            end

        end     
        Citizen.Wait(_sleep)
    end       
end)
--
Create3D = function(coords, texto)
    local x, y, z = table.unpack(coords)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(5)
        AddTextComponentString(texto)
        DrawText(_x,_y)
    end
end

SpawnNPC = function(modelo, x,y,z,h)
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
