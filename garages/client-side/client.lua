-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cnVRP = {}
Tunnel.bindInterface("garages",cnVRP)
vSERVER = Tunnel.getInterface("garages") 
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local vehicle = {}
local cooldown = 0
local trydoors = {}
local searchBlip = nil
local openGarage = ""
local pointGarage = 1
local vehHotwired = false
local anim = "machinic_loop_mechandplayer"
local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
local spawn = { }
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHELETRIC
-----------------------------------------------------------------------------------------------------------------------------------------
local vehEletric = {
	["voltic"] = true,
	["raiden"] = true,
	["neon"] = true,
	["tezeract"] = true,
	["cyclone"] = true,
	["surge"] = true,
	["dilettante"] = true,
	["dilettante2"] = true,
	["bmx"] = true,
	["cruiser"] = true,
	["fixter"] = true,
	["scorcher"] = true,
	["tribike"] = true,
	["tribike2"] = true,
	["tribike3"] = true,
	["teslaprior"] = true
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.openGarage(garage,spawns)

	spawn = spawns
	openGarage = garage.tipo

	SetNuiFocus(true,true)
	SendNUIMessage({ action = "openNUI" })
end

Citizen.CreateThread(function()
	Citizen.Wait(15000)
	TriggerServerEvent("autorizarPlate","11AAA000")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLEMODS
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.vehicleMods(veh,custom)
	local veh = GetObjectIndexFromEntityIndex(veh)
	if custom and veh then
		SetVehicleModKit(veh,0)
		if custom.color then
			SetVehicleColours(veh,tonumber(custom.color[1]),tonumber(custom.color[2]))
			SetVehicleExtraColours(veh,tonumber(custom.extracolor[1]),tonumber(custom.extracolor[2]))
		end

		if custom.customPcolor then
			SetVehicleCustomPrimaryColour(veh,tonumber(custom.customPcolor[1]),tonumber(custom.customPcolor[2]),tonumber(custom.customPcolor[3]))
		end
		
		if custom.customScolor then
			SetVehicleCustomSecondaryColour(veh,tonumber(custom.customScolor[1]),tonumber(custom.customScolor[2]),tonumber(custom.customScolor[3]))
		end

		if custom.smokecolor then
			SetVehicleTyreSmokeColor(veh,tonumber(custom.smokecolor[1]),tonumber(custom.smokecolor[2]),tonumber(custom.smokecolor[3]))
		end
		
		if custom.neon then
			SetVehicleNeonLightEnabled(veh,0,1)
			SetVehicleNeonLightEnabled(veh,1,1)
			SetVehicleNeonLightEnabled(veh,2,1)
			SetVehicleNeonLightEnabled(veh,3,1)
			SetVehicleNeonLightsColour(veh,tonumber(custom.neoncolor[1]),tonumber(custom.neoncolor[2]),tonumber(custom.neoncolor[3]))
		else
			SetVehicleNeonLightEnabled(veh,0,0)
			SetVehicleNeonLightEnabled(veh,1,0)
			SetVehicleNeonLightEnabled(veh,2,0)
			SetVehicleNeonLightEnabled(veh,3,0)
		end

		if custom.xenoncolor then
			SetVehicleXenonLightsColor(veh,custom.xenoncolor)
		end

		if custom.plateindex then
			SetVehicleNumberPlateTextIndex(veh,tonumber(custom.plateindex))
		end

		if custom.windowtint then
			SetVehicleWindowTint(veh,tonumber(custom.windowtint))
		end

		if custom.bulletProofTyres then
			SetVehicleTyresCanBurst(veh,custom.bulletProofTyres)
		end

		if custom.wheeltype then
			SetVehicleWheelType(veh,tonumber(custom.wheeltype))
		end

		if custom.mods then
			for i = 0,16 do
				SetVehicleMod(veh,i,tonumber(custom.mods[tostring(i)].mod))
			end
			SetVehicleMod(veh,23,tonumber(custom.mods['23']['mod']),custom.mods['23']['variation'])
			SetVehicleMod(veh,24,tonumber(custom.mods['24']['mod']),custom.mods['24']['variation'])
		
			if IsThisModelABike(GetEntityModel(veh)) then
				SetVehicleMod(veh,24,tonumber(custom.mods['24']['mod']),tonumber(custom.mods['24']['variation']))
			end
			for i = 25,48 do
				SetVehicleMod(veh,i,tonumber(custom.mods[tostring(i)].mod))
			end
			SetVehicleLivery(veh,tonumber(custom.liveries))

			ToggleVehicleMod(veh,20,tonumber(custom.mods[tostring(20)].mod))
			ToggleVehicleMod(veh,22,tonumber(custom.mods[tostring(22)].mod))
			ToggleVehicleMod(veh,18,tonumber(custom.mods[tostring(18)].mod))
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.spawnVehicle(vehname,plate,vehengine,vehbody,vehfuel,custom,vehWindows,vehDoors,vehTyres)
	--if not vSERVER.returnVehicle(source,name) then
	if vehicle[vehname] == nil then
	
		local checkslot = 0
		local mHash = GetHashKey(vehname)

		RequestModel(mHash)
		while not HasModelLoaded(mHash) do
			RequestModel(mHash)
			Citizen.Wait(10)
		end

		if HasModelLoaded(mHash) then

			local pos_livre = nil
			
			for k, v in pairs(spawn) do
				
				Citizen.Wait(1)

				local checkPos = GetClosestVehicle(v.x+0.0,v.y+0.0,v.z+0.0,2.501,0,71)
				--print(checkPos)
				--print(DoesEntityExist(checkPos))
				if not DoesEntityExist(checkPos) then 
					pos_livre = v
				end
			end

			if pos_livre == nil then
				TriggerEvent("Notify","info","Todas as vagas estão atualmente ocupadas.",5000)
			else
				local _,cdz = GetGroundZFor_3dCoord(pos_livre.x+0.0,pos_livre.y+0.0,pos_livre.z+1)
				--local teste = CreateVehicle(mHash,pos_livre.x+0.0,pos_livre.y+0.0,cdz,pos_livre.h+0.0,true,true)
				local nveh = vSERVER.createVehicle(mHash,pos_livre.x+0.0,pos_livre.y+0.0,cdz,pos_livre.h+0.0,plate,vehBody,vehDoors)

				local nveh = NetToEnt(nveh)
				cnVRP.vehicleMods(nveh,custom) 

				NetworkRegisterEntityAsNetworked(nveh)
				while not NetworkGetEntityIsNetworked(nveh) do
					Citizen.Wait(10)
				end

				

				if json.decode(vehWindows) ~= nil then
					for k,v in pairs(json.decode(vehWindows)) do
						if not v then
							SmashVehicleWindow(nveh,parseInt(k))
						end
					end
				end

				if json.decode(vehTyres) ~= nil then
					for k,v in pairs(json.decode(vehTyres)) do
						if v < 2 then
							SetVehicleTyreBurst(nveh,parseInt(k),(v == 1),1000.01)
						end
					end
				end

				SetEntityAsMissionEntity(nveh,true,true)
				SetVehicleOnGroundProperly(nveh)
				SetVehRadioStation(nveh,"OFF")
				SetVehicleDirtLevel(nveh,0.0)

				SetVehicleEngineHealth(nveh,vehengine+0.0) 
				SetVehicleBodyHealth(nveh,vehbody+0.0)

				if vehEletric[vehname] then
					SetVehicleFuelLevel(nveh,0.0)
				else
					SetVehicleFuelLevel(nveh,vehfuel+0.0)
				end

				vehicle[vehname] = true

				local netid = NetworkGetNetworkIdFromEntity(nveh) --VehToNet(nveh)
				SetNetworkIdExistsOnAllMachines(netid,true)
				NetworkSetNetworkIdDynamic(netid,true)
				SetNetworkIdCanMigrate(netid,false)
				for _,i in ipairs(GetActivePlayers()) do
					SetNetworkIdSyncToPlayer(netid,i,true)
					SetVehicleDoorsLockedForAllPlayers(nveh,true)
				end

				SetModelAsNoLongerNeeded(mHash)

				return true,netid
			end
		end
	--end
	else
		return false
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.deleteVehicle(vehicle)
	if IsEntityAVehicle(vehicle) then
		local vehDoors = {}
		for i = 0,5 do
			vehDoors[i] = IsVehicleDoorDamaged(vehicle,i)
		end

		local vehWindows = {}
		for i = 0,7 do
			vehWindows[i] = IsVehicleWindowIntact(vehicle,i)
		end

		local vehTyres = {}
		for i = 0,7 do
			local tyre_state = 2
			if IsVehicleTyreBurst(vehicle,i,true) then
				tyre_state = 1
			elseif IsVehicleTyreBurst(vehicle,i,false) then
				tyre_state = 0
			end
			vehTyres[i] = tyre_state
		end

		vSERVER.tryDelete(VehToNet(vehicle),GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle),vehDoors,vehWindows,vehTyres,GetVehicleNumberPlateText(vehicle))
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:syncVehicle")
AddEventHandler("garages:syncVehicle",function(index,plate)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) and GetVehicleNumberPlateText(v) == plate then
			SetEntityAsMissionEntity(v,false,false)
			DeleteEntity(v)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCNAMEDELETE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.syncNameDelete(vehname)
	if vehicle[vehname] then
		vehicle[vehname] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.returnVehicle(name)
	return vehicle[name]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONCLICK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close",function(data,cb)
	SetNuiFocus(false,false)
    SendNUIMessage({ action = "closeNUI" })
    cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("myVehicles",function(data,cb)
	local vehicles = vSERVER.myVehicles(openGarage)
	if vehicles then
		cb({ vehicles = vehicles })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("spawnVehicles",function(data)
	vSERVER.spawnVehicles(data.name)
	SetNuiFocus(false,false)
    SendNUIMessage({ action = "closeNUI" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("deleteVehicles",function(data)
	vSERVER.deleteVehicles()
	SetNuiFocus(false,false)
    SendNUIMessage({ action = "closeNUI" })
end)

RegisterNetEvent("garages:deleteVehicles")
AddEventHandler("garages:deleteVehicles",function()
	vSERVER.deleteVehicles()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLECLIENTLOCK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:vehicleClientLock")
AddEventHandler("garages:vehicleClientLock",function(index,lock)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToEnt(index)
		if DoesEntityExist(v) then
			if lock == 1 then
				SetVehicleDoorsLockedForAllPlayers(v,false)
			else
				SetVehicleDoorsLockedForAllPlayers(v,true)
			end
		end
	end
end)
Citizen.CreateThread(function()
    local innerTable = {}
    for k,v in pairs(spawn) do
        table.insert(innerTable,{ v[1],v[2],v[3],2,"E","Garagem pressione","Para abrir" })
    end

    TriggerEvent("hoverfy:insertTable",innerTable)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Citizen.CreateThread(function()
-- 	SetNuiFocus(false,false) 

-- 	while true do
-- 		local timeDistance = 500
-- 		local ped = PlayerPedId()
-- 		if not IsPedInAnyVehicle(ped) then
-- 			local coords = GetEntityCoords(ped)
-- 			for k,v in pairs(spawn) do
-- 				local distance = #(coords - vector3(v[1],v[2],v[3]))
-- 				if distance <= 20 then
-- 					timeDistance = 4
-- 					--DrawMarker(36, v[1],v[2],v[3] - 0.80, 0,0, 0,0, 0,0, 0.2, 0.2, 0.2, 70, 30, 200, 80, 1, 0, 0, 0)
-- 					--DrawMarker(23, v[1],v[2],v[3] - 0.97, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 70, 30, 200, 80, 0, 0, 0, 0)
-- 					DrawMarker(36,v[1],v[2],v[3] - 0.80,0,0,0,0,0,0,0.29,0.35,0.40,255,16,16,100,0,0,0,1)
-- 					DrawMarker(23,v[1],v[2],v[3]- 0.97,0,0,0,0,0,0,1.00,1.00,1.00,255,16,16,100,0,0,0,0)
-- 					if distance <= 2 then
-- 						if IsControlJustPressed(1,38) then
-- 							vSERVER.returnHouses(v[4],k)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end

-- 		Citizen.Wait(timeDistance)
-- 	end
-- end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COOLDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if cooldown > 0 then
			cooldown = cooldown - 1
		end
		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONLOCK
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if cooldown <= 0 then
			timeDistance = 5
			if IsControlJustPressed(1,182) then
				vSERVER.vehicleLock()
				cooldown = 1
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCTRYDOORS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("garages:syncTrydoors")
AddEventHandler("garages:syncTrydoors",function(doors)
	trydoors = doors
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTANIMHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.startAnimHotwired()
	vehHotwired = true
	while not HasAnimDictLoaded(animDict) do
		RequestAnimDict(animDict)
		Citizen.Wait(10)
	end
	TaskPlayAnim(PlayerPedId(),animDict,anim,3.0,3.0,-1,49,5.0,0,0,0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPANIMHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.stopAnimHotwired(vehicle)
	while not HasAnimDictLoaded(animDict) do
		RequestAnimDict(animDict)
		Citizen.Wait(10)
	end
	vehHotwired = false
	StopAnimTask(PlayerPedId(),animDict,anim,2.0)
	SetEntityAsMissionEntity(vehicle,true,true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.updateHotwired(status)
	vehHotwired = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOPHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsUsing(ped)
			local platext = GetVehicleNumberPlateText(vehicle)
			if GetPedInVehicleSeat(vehicle,-1) == ped and not trydoors[platext] or GetEntityHealth(ped) <= 101 then
				SetVehicleEngineOn(vehicle,false,true,true)
				DisablePlayerFiring(ped,true)
				timeDistance = 4
			end

			if vehHotwired and vehicle then
				DisableControlAction(1,75,true)
				DisableControlAction(1,20,true)
				timeDistance = 4
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

local debug = false
local garages = nil

RegisterCommand("criargarage", function(source, args, rawCommand)

	if vSERVER.permissao() then 

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		local pos_spawn  = {}

		local h = GetEntityHeading(GetPlayerPed(-1))

		while true do

		--drawTxt("\nBotão esquerdo do mouse para colocar bola e o direito para cancelar",1,0.5,0.93,0.5,255,255,255,180)
		drawTxt("\nBotão esquerdo do mouse para colocar bola e o direito para cancelar", 0.215,0.5)

		local ped = GetPlayerPed(-1)
		local start = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
		local fin = GetOffsetFromEntityInWorldCoords(ped, 0.0, 20.0, -10.0)
		local ray = StartShapeTestRay(start.x,start.y,start.z,fin.x,fin.y,fin.z,16,ped,5000)
		local _ray,hit,pos,norm,ent = GetShapeTestResult(ray)
	
		local rayB = StartShapeTestRay(start.x,start.y,start.z,fin.x,fin.y,fin.z,1,ped,5000)
		local _rayB,hitB,posB,normB,entB = GetShapeTestResult(rayB)
		

		local grau_spanw = 0
			
			
				DrawMarker(43,posB,0,0,0,0,0,h,4.75,2.21,1.06,0,255,255,100,0,0,0,0)
				grau_spanw = 90
				--drawTxt("\nBotão ~r~E~w~ para rotacionar",1,0.5,0.90,0.5,255,255,255,180)
				drawTxt("\nBotão ~r~E~w~ para rotacionar", 0.215,0.94)
				if IsControlPressed(1,38) then
					h = h + 1
				end
			

			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,142,true)
	
			if IsDisabledControlJustReleased(0,24) then

				local p = {
					x = posB.x,
					y = posB.y,
					z = posB.z,
					h = h-90.0
				} 

				table.insert(pos_spawn,p)
				TriggerEvent("Notify","check","Ponto de Spawn Adicionado com sucesso.",20000)

			elseif IsDisabledControlJustReleased(0,25) then
				break
			end
		Wait(0)
		end

		vSERVER.addGaragem({x = coords[1], y = coords[2], z = coords[3]}, pos_spawn )
		
		
	end

end)

RegisterCommand("debuggarage", function(source, args, rawCommand)
	if vSERVER.permissao() then 
		debug = not debug
	end
end)

RegisterCommand("criarspawngarage", function(source, args, rawCommand)
	if vSERVER.permissao() and args[1] then
		local id = args[1]
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local h = GetEntityHeading(ped)

		vSERVER.addGaragemSpawn({idGaragem = id, x = coords[1], y = coords[2], z = coords[3], h = h})
	end
end)

RegisterCommand("excluirgarage", function(source, args, rawCommand)

	if vSERVER.permissao() then 
		local id = args[1]
		vSERVER.removeGaragem({id = id})
	end

end)


RegisterNetEvent("garages:atualizarGarages")
AddEventHandler("garages:atualizarGarages",function(garages_temp)
	garages = garages_temp
end)

Citizen.CreateThread(function()

	garages = vSERVER.getGaragem()

	while true do
		local time = 500

		local ped = PlayerPedId()

		if garages then
			for key, value in pairs(garages) do

				local coords = GetEntityCoords(ped)
				local distance = #(vector3(coords[1], coords[2], coords[3]) - vector3(parseInt(value.x),parseInt(value.y), parseInt(value.z)))

				if distance < 10 then
					time = 1

					if debug then 
						--DrawText3D(value.x+0.0, value.y+0.0, value.z+0.0, "GARAGEM: "..value.id)
						DrawText3Ds(value.x+0.0, value.y+0.0, value.z+0.0, "GARAGEM: "..value.id)
					end

					DrawMarker(23,value.x+0.0,value.y+0.0,value.z-0.95,0,0,0,0,0,0,1.00,1.00,1.00,0,255,255,100,0,0,0,0)

					if distance < 1.7 then
						if IsControlJustPressed(1,38) then

							-- abrir a garage aqui

							vSERVER.returnHouses(value)

						end
					end

				end

			end

		else 
			time = 5000
			garages = vSERVER.getGaragem()
		end

		Citizen.Wait(time)
	end
end)

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80)
end

function drawTxt(text,x,y)
	local res_x, res_y = GetActiveScreenResolution()

	SetTextFont(4)
	SetTextScale(0.3,0.3)
	SetTextColour(255,255,255,255)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)

	if res_x >= 2000 then
		DrawText(x+0.076,y)
	else
		DrawText(x,y)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOPHOTWIRED
-----------------------------------------------------------------------------------------------------------------------------------------
local garagens = {
    { 213.90,-809.08,31.01},
    { 596.69,91.42,93.12},
    { 275.8,-344.22,45.18},
    { 56.08,-876.53,30.65},
    { -348.95,-874.39,31.31},
    { -340.64,266.31,85.67},
    { -777.33,5591.45,33.49},
    { 322.25,2617.71,44.49},
    { 1036.02,-763.13,58.0},
    { -1184.93,-1509.98,4.64},
    { -73.32,-2004.20,18.27},
	{ 1695.37,4774.67,42.0 },
	{ -45.68,6551.73,31.57 }
}

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local x,y,z = table.unpack(GetEntityCoords(ped))
    
        if z < -110 then
            if IsPedInAnyVehicle(ped) then
                cnVRP.deleteVehicle(GetVehiclePedIsIn(ped))
                -- COLOCAR SUA FUNÇÃO DE DELETAR O VEICULO E PASSAR O VALOR: GetVehiclePedIsIn(ped)
                teleportPlayerProxmityCoords(x,y,z)
                TriggerEvent('Notify', 'info', 'Você caiu no limbo com seu veiculo e foi teleportado para a garagem mais proxima.', 10000)
            end
        end

        Citizen.Wait(1000)
    end
end)

function teleportPlayerProxmityCoords(x,y,z)
    local array = {}
    local coordenadas = {}

    for k,v in pairs(garagens) do
        local distanceAtual = parseInt(Vdist2(v[1],v[2],v[3], td(x),td(y),td(z)))
        table.insert(array, distanceAtual)
        coordenadas[distanceAtual] = { x = v[1], y = v[2], z = v[3] }
    end

    if coordenadas[math.min(table.unpack(array))] then
        SetEntityCoords(PlayerPedId(),coordenadas[math.min(table.unpack(array))].x,coordenadas[math.min(table.unpack(array))].y,coordenadas[math.min(table.unpack(array))].z)
    end

end

function td(n)
    n = math.ceil(n * 100) / 100
    return n
end 

-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHBLIP
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.searchBlip(vehCoords)
	if DoesBlipExist(searchBlip) then
		RemoveBlip(searchBlip)
		searchBlip = nil
	end

	searchBlip = AddBlipForCoord(vehCoords["x"],vehCoords["y"],vehCoords["z"])
	SetBlipSprite(searchBlip,225)
	SetBlipColour(searchBlip,2)
	SetBlipScale(searchBlip,0.6)
	SetBlipAsShortRange(searchBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Veículo")
	EndTextCommandSetBlipName(searchBlip)

	SetTimeout(30000,function()
		RemoveBlip(searchBlip)
		searchBlip = nil
	end)
end