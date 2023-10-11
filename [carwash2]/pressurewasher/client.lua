-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
studiodz7 = {}
Tunnel.bindInterface("pressurewasher",studiodz7)
vSERVER = Tunnel.getInterface("pressurewasher")

AddEventHandler('pwasher:requestEquipPump', function()
    --if vSERVER.payment(source) then
        TriggerEvent("pwasher:equipPump")
    --end
end)

AddEventHandler('pwasher:playSplashParticle', function(pname, posx, posy, posz, heading)
	Citizen.CreateThread(function()
        UseParticleFxAssetNextCall("core")
        local pfx = StartParticleFxLoopedAtCoord(pname, posx, posy, posz, 0.0, 0.0, heading, 1.0, false, false, false, false)
        local Vehicle = VehicleProx(10)
        local Vehicle = VehToNet(Vehicle)

        if Vehicle then
            --TriggerEvent("Progress",10000)
            local Vehicle = NetworkGetEntityFromNetworkId(Vehicle)
            if DoesEntityExist(Vehicle) and not IsPedAPlayer(Vehicle) and GetEntityType(Vehicle) == 2 then
                local timer = GetVehicleDirtLevel(Vehicle)
                while timer > 0.0 and IsControlJustPressed(0,24) do
                    timer = GetVehicleDirtLevel(Vehicle) - 0.1
                    SetVehicleDirtLevel(Vehicle, timer)
                    if timer <= 0.0 then
						TriggerClientEvent("Notify",source,"check","Veiculo totalmente limpo !",5000)
                        SetVehicleDirtLevel(Vehicle, 0.0)
                        timer = 0.0
                    end
                    Citizen.Wait(1300)
                end
            end
		end
        Citizen.Wait(100)
        StopParticleFxLooped(pfx, 0)
    end)
end)

AddEventHandler('pwasher:playWaterParticle', function(pname, entity, density)
    print("Play Particle")
    
	Citizen.CreateThread(function()
        for i = 0, density, 1 do
            UseParticleFxAssetNextCall("core")
            StartParticleFxNonLoopedOnEntity(pname, objID, 0.5, 0.0, 0.0, 90.0, 0.0, -90.0, 1.0, true, true, true)
            
        end
        
    end)
end)

Citizen.CreateThread(function()
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
         Citizen.Wait(1)
         
    end
end)

function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- NEARVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function nVehicle(radius)
	local vehList = {}
	local vehReturn = {}
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)

	local _next,_vehicle = FindFirstVehicle()
	if _vehicle then
		table.insert(vehList,_vehicle)
	end

	repeat
		local _nextVehicle,_vehicle = FindNextVehicle(_next)
		if _nextVehicle and _vehicle then
			table.insert(vehList,_vehicle)
		end
	until not _nextVehicle

	EndFindVehicle(_next)

	for k,v in pairs(vehList) do
		local uCoords = GetEntityCoords(v)
		local distance = #(coords - uCoords)
		if distance <= radius then
			vehReturn[v] = distance
		end
	end

	return vehReturn
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEARVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function VehicleProx(radius)
	local vehSelect = false
	local minRadius = radius + 0.0001
	local vehList = nVehicle(radius)

	for _vehicle,_distance in pairs(vehList) do
		if _distance <= minRadius then
			minRadius = _distance
			vehSelect = _vehicle
		end
	end

	return vehSelect
end

