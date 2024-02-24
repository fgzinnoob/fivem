-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP") 
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cnVRP = {}
Tunnel.bindInterface("garages",cnVRP)
vCLIENT = Tunnel.getInterface("garages")
vHUD = Tunnel.getInterface("hud")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local vehlist = {}
local trydoors = {}
local stealVehs = {}
local spanwedVehs = {}
local vehSpawn = {}
local vehSignal = {}
local searchTimers = {}
local vehChest = {}
local deleteVehicles = {}
local webhookdeletcar = "https://discord.com/api/webhooks/1100447480153387009/pdyDRVS0xqoEHXAaEPhHqytu1Vd-h9yVLgOVnzCdP6GpiQg-2Re5v7p8curUqBVBfqCD"
local webhookcar = "https://discord.com/api/webhooks/1101334784438976572/bM2XPjlOXfk1EatQeRToRfWw6d1q21LwCyoBKWqxMg9FZg7oeEsY3zZAngvcnyabgvcF"

vRP.prepare("insert_table_garage", "INSERT INTO garage (x, y, z, tipo, perm) VALUES(@x, @y, @z, @tipo, @perm);")
vRP.prepare("insert_table_garage_spawn", "INSERT INTO garage_spawn (idGaragem, x, y, z, h) VALUES(@idGaragem, @x, @y, @z, @h);")
vRP.prepare("delete_table_garage", "DELETE FROM garage WHERE id = @id;")
vRP.prepare("delete_table_garage_spawn", "DELETE FROM garage_spawn WHERE idGaragem = @id;")
--vRP.prepare("select_table_garage", "SELECT g.id as idGaragem, g.x as xGaragem, g.y as yGaragem, g.z as zGaragem, g.tipo, s.id as idSpawn, s.x as xSpawn, s.y as ySpawn, s.z as zSpawn, s.h as hSpawn FROM garage AS g LEFT JOIN garage_spawn AS s ON g.id = s.idGaragem")
vRP.prepare("select_ult_id_garage", "SELECT id FROM garage ORDER BY id desc LIMIT 1")

vRP.prepare("select_table_garage", "SELECT * FROM garage")
vRP.prepare("select_table_garage_spawns", "SELECT * FROM garage_spawn where idGaragem = @idGaragem")

vRP.prepare("select_table_garage_tipos", "SELECT * FROM garage_tipo_veh where tipo = @tipo")



--garage definition
function SendWebhook(webhook,embed)
    PerformHttpRequest(webhook, function(err, text, headers) end,'POST',
    json.encode({username = "CPX_DZ7_MOCHILA", embeds = embed, avatar_url = "https://media.discordapp.net/attachments/1079273112677404682/1079273335961157753/logo.png",}),
    { ['Content-Type'] = 'application/json' })
end
-- function SendWebhookMessage(webhook,message)
-- 	if webhook ~= nil and webhook ~= "" then
-- 		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
-- 	end
-- end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPLATEEVERYONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("setPlateEveryone")
AddEventHandler("setPlateEveryone",function(plate)
	trydoors[plate] = true
	TriggerClientEvent("garages:syncTrydoors",-1,trydoors)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPLATEEVERYONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("setPlatePlayers")
AddEventHandler("setPlatePlayers",function(vehPlate,user_id)
	local plateId = vRP.getVehiclePlate(vehPlate)
	if not plateId then
		stealVehs[vehPlate] = parseInt(user_id)
	end
end)

RegisterServerEvent('autorizarPlate')
AddEventHandler('autorizarPlate', function(plate)
	local source = source
	local user_id = vRP.getUserId(source)
    TriggerEvent("setPlateEveryone",plate)
	TriggerEvent("setPlatePlayers",plate,user_id)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source)
	TriggerClientEvent("garages:syncTrydoors",source,trydoors)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SIGNALREMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("signalRemove")
AddEventHandler("signalRemove",function(vehPlate)
	vehSignal[vehPlate] = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MYVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.myVehicles(work)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then

		local myvehicles = {}

		if work ~= "garage" then
					
			local workgarage = vRP.query("select_table_garage_tipos",{ tipo = work})

			for k,v in pairs(workgarage) do
				local veh = vRP.query("vRP/get_vehicles",{ user_id = parseInt(user_id), vehicle = tostring(v.vehicle) })
				if veh[1] then
					table.insert(myvehicles,{ name = veh[1].vehicle, name2 = vRP.vehicleName(veh[1].vehicle), engine = parseInt(veh[1].engine*0.1), body = parseInt(veh[1].body*0.1), fuel = parseInt(veh[1].fuel), engine2 = "DESATIVADO", freio = "DESATIVADO", transm = "DESATIVADO", susp = "DESATIVADO", blind = "DESATIVADO", turbo = "DESATIVADO" })
				else
					table.insert(myvehicles,{ name = v.vehicle, name2 = vRP.vehicleName(v.vehicle), engine = 100, body = 100, fuel = 100, engine2 = "DESATIVADO", freio = "DESATIVADO", transm = "DESATIVADO", susp = "DESATIVADO", blind = "DESATIVADO", turbo = "DESATIVADO" })
				end
			end
			
		else
			local vehicle = vRP.query("vRP/get_vehicle",{ user_id = parseInt(user_id) })
			for k,v in ipairs(vehicle) do
				if v.work == "false" then
					local tuning = json.decode(vRP.getSData("custom:"..user_id..":"..vehicle[k].vehicle))
					local nVehicle = { name = vehicle[k].vehicle, name2 = vRP.vehicleName(vehicle[k].vehicle), engine = parseInt(vehicle[k].engine*0.1), body = parseInt(vehicle[k].body*0.1), fuel = parseInt(vehicle[k].fuel), engine2 = "DESATIVADO", freio = "DESATIVADO", transm = "DESATIVADO", susp = "DESATIVADO", blind = "DESATIVADO", turbo = "DESATIVADO" }
					if tuning then
						nVehicle.engine2 = tuning.engine
						nVehicle.freio = tuning.brakes
						nVehicle.transm = tuning.transmission
						nVehicle.susp = tuning.suspension
						nVehicle.blind = tuning.armor
						nVehicle.turbo = tuning.turbo

						if nVehicle.engine2 == -1 then
							nVehicle.engine2 = "DESATIVADO"
						elseif nVehicle.engine2 == 0 then
							nVehicle.engine2 = "Nível 1 / 5"
						elseif nVehicle.engine2 == 1 then
							nVehicle.engine2 = "Nível 2 / 5"
						elseif nVehicle.engine2 == 2 then
							nVehicle.engine2 = "Nível 3 / 5"
						elseif nVehicle.engine2 == 3 then
							nVehicle.engine2 = "Nível 4 / 5"
						elseif nVehicle.engine2 == 4 then
							nVehicle.engine2 = "Nível 5 / 5"
						end
				
						if nVehicle.freio == -1 then
							nVehicle.freio = "DESATIVADO"
						elseif nVehicle.freio == 0 then
							nVehicle.freio = "Nível 1 / 3"
						elseif nVehicle.freio == 1 then
							nVehicle.freio = "Nível 2 / 3"
						elseif nVehicle.freio == 2 then
							nVehicle.freio = "Nível 3 / 3"
						end
				
						if nVehicle.transm == -1 then
							nVehicle.transm = "DESATIVADO"
						elseif nVehicle.transm == 0 then
							nVehicle.transm = "Nível 1 / 4"
						elseif nVehicle.transm == 1 then
							nVehicle.transm = "Nível 2 / 4"
						elseif nVehicle.transm == 2 then
							nVehicle.transm = "Nível 3 / 4"
						elseif nVehicle.transm == 3 then
							nVehicle.transm = "Nível 4 / 4"
						end

						if nVehicle.susp == -1 then
							nVehicle.susp = "DESATIVADO"
						elseif nVehicle.susp == 0 then
							nVehicle.susp = "Nível 1 / 5"
						elseif nVehicle.susp == 1 then
							nVehicle.susp = "Nível 2 / 5"
						elseif nVehicle.susp == 2 then
							nVehicle.susp = "Nível 3 / 5"
						elseif nVehicle.susp == 3 then
							nVehicle.susp = "Nível 4 / 5"
						elseif nVehicle.susp == 4 then
							nVehicle.susp = "Nível 5 / 5"
						end
					
						if nVehicle.blind == -1 then
							nVehicle.blind = "DESATIVADO"
						elseif nVehicle.blind == 0 then
							nVehicle.blind = "Nível 1 / 5"
						elseif nVehicle.blind == 1 then
							nVehicle.blind = "Nível 2 / 5"
						elseif nVehicle.blind == 2 then
							nVehicle.blind = "Nível 3 / 5"
						elseif nVehicle.blind == 3 then
							nVehicle.blind = "Nível 4 / 5"
						elseif nVehicle.blind == 4 then
							nVehicle.blind = "Nível 5 / 5"
						end
					end
					nVehicle.detido = parseInt(os.time()) <= parseInt(vehicle[k].time+24*60*60)

					vehChest[parseInt(user_id)] = "chest:"..parseInt(user_id)..":"..vehicle[k].vehicle
					local inv = vRP.getInventory(parseInt(user_id))
					local data = vRP.getSData(vehChest[parseInt(user_id)])
					local sdata = json.decode(data) or {}
					nVehicle.pmalas = vRP.computeChestWeight(sdata)
					nVehicle.pmalas2 = vRP.vehicleChest(vehicle[k].vehicle)
					if nVehicle.detido == false then
						nVehicle.detido = "Nao"
					elseif nVehicle.detido == true then
						nVehicle.detido = "Sim"
					end
					table.insert(myvehicles, nVehicle)				
		
				end
			end
		end
		return myvehicles
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.spawnVehicles(name)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id and name then
        --if not cnVRP.returnVehicle(name,user_id) then
            local vehicle = vRP.query("vRP/get_vehicles",{ user_id = parseInt(user_id), vehicle = name })
			local vehPlate = vehicle[1].plate
			if vehicle[1] == nil then
				vRP.execute("vRP/add_vehicle",{ user_id = parseInt(user_id), vehicle = name, plate = vRP.generatePlateNumber(), phone = vRP.getPhone(user_id), work = tostring(true) })
				vehicle = vRP.query("vRP/get_vehicles",{ user_id = parseInt(user_id), vehicle = name })
			else
				if vehSpawn[vehPlate] then
					if vehSignal[vehPlate] == nil then
						
						if searchTimers[user_id] == nil then
							searchTimers[user_id] = os.time()
						end
				
						if os.time() >= parseInt(searchTimers[user_id]) then
							local gps = vRP.request(source,"Deseja pagar <b>$1,500.00</b> Dollars Para Rastrearmos seu veiculo ? (Caso não for encontrado ele volta para garagem.)",60)
							if gps  then
								if vRP.paymentBank(user_id,1500) then
									searchTimers[user_id] = os.time() + 60
									local vehNet = vehSpawn[vehPlate][3]
									local idNetwork = NetworkGetEntityFromNetworkId(vehNet)
									if DoesEntityExist(idNetwork) and not IsPedAPlayer(idNetwork) and GetEntityType(idNetwork) == 2 then
										vCLIENT.searchBlip(source,GetEntityCoords(idNetwork))
										TriggerClientEvent("Notify",source,"info","Rastreador do veículo foi ativado por <b>30 segundos</b>, lembrando que se o mesmo estiver em movimento a localização pode ser imprecisa.",10000)
									else
										if vehSpawn[vehPlate] then
											vehSpawn[vehPlate] = nil
										end
										TriggerClientEvent("Notify",source,"check","A seguradora efetuou o resgate do seu veículo e o mesmo já se encontra disponível para retirada.",5000)
									end
								else
									TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
								end		
							end
						else
							TriggerClientEvent("Notify",source,"info","Rastreador só pode ser ativado a cada <b>60 segundos</b>.",5000)
						end
					else
						TriggerClientEvent("Notify",source,"error","Rastreador está desativado.",5000)
					end
				end
			end

			if vRP.vehicleType(tostring(name)) == "donate" and vRP.getCarPremium(name,user_id) then
				local status = vRP.request(source,"Veículo esta com IPVA atrasado, deseja pagar o IPVA deste veiculo por <b>$"..vRP.format(parseInt(vRP.vehiclePrice(name)*0.04)).."</b> Dollars?",60)
				if status then
					if vRP.paymentBank(user_id,parseInt(vRP.vehiclePrice(name)*0.04)) then--if vRP.remGmsId(user_id,parseInt(vRP.vehiclePrice(name)*0.01)) then
						vRP.execute("vRP/set_rental_time",{ user_id = parseInt(user_id), vehicle = name, premiumtime = parseInt(os.time()) })
					else
						TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
					end
				end
			elseif not vRP.vehicleType(tostring(name)) == "donate" and parseInt(os.time()) >= parseInt(vehicle[1].ipva+14*60*60) then
				local status = vRP.request(source,"Veículo esta com IPVA atrasado, deseja pagar o IPVA deste veiculo por <b>$"..vRP.format(parseInt(vRP.vehiclePrice(name)*0.04)).."</b> Dollars?",60)
				if status then
					if vRP.paymentBank(user_id,parseInt(vRP.vehiclePrice(name)*0.04)) then--if vRP.remGmsId(user_id,parseInt(vRP.vehiclePrice(name)*0.01)) then
						vRP.execute("vRP/set_ipva_time",{ user_id = parseInt(user_id), vehicle = name, ipva = parseInt(os.time()) })
					else
						TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
					end
				end
			elseif parseInt(vehicle[1].arrest) >= 1 then
				local status = vRP.request(source,"Veículo detido, deseja acionar o seguro pagando <b>$"..vRP.format(parseInt(vRP.vehiclePrice(name)*0.1)).."</b> dólares?",60)
				if status then
					if vRP.paymentBank(user_id,parseInt(vRP.vehiclePrice(name)*0.1)) then
						vRP.execute("vRP/set_arrest",{ user_id = parseInt(user_id), vehicle = name, arrest = 0, time = 0 })
					else
						TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
					end
				end
			elseif parseInt(vehicle[1].desmanchado) >= 1 then
				local taxaSeguro = parseInt(vRP.vehiclePrice(name)*0.3)
				local status = vRP.request(source,"Veículo desmanchado, deseja acionar o seguro pagando <b>$"..vRP.format(taxaSeguro).." dólares?",60)
				if status then
					if vRP.paymentBank(user_id,taxaSeguro) then
						vRP.execute("vRP/set_desmanchado",{ user_id = parseInt(user_id), vehicle = name, desmanchado = 0 })
					else
						TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
					end
				end
			else
				local tuning = vRP.getSData("custom:"..user_id..":"..name) or {}
				local custom = json.decode(tuning) or {}

				if vehicle[1].plate == nil then
					vehicle[1].plate = vRP.generatePlateNumber()
					vRP.execute("vRP/update_plate_vehicle",{ user_id = parseInt(user_id), vehicle = name, plate = vehicle[1].plate })
				end

				if vehicle[1].phone == nil then
					vehicle[1].phone = vRP.getPhone(user_id)
					vRP.execute("vRP/update_phone_vehicle",{ user_id = parseInt(user_id), vehicle = name, phone = vehicle[1].phone })
				end

				-- if not vRP.getPremium(parseInt(user_id)) then
				-- 	print("entrou aqui")
				-- 	if vRP.getBank(parseInt(user_id)) >= parseInt(vRP.vehiclePrice(name)*0.05) then
				-- 		local status,vehid = vCLIENT.spawnVehicle(source,name,vehicle[1].plate,vehicle[1].engine,vehicle[1].body,vehicle[1].fuel,custom,vehicle[1].windows,vehicle[1].doors,vehicle[1].tyres)
				-- 		if status and vRP.paymentBank(parseInt(user_id),parseInt(vRP.vehiclePrice(name)*0.05)) then
				-- 			vehlist[vehid] = { parseInt(user_id),name }
				-- 			spanwedVehs[name..user_id] = true

				-- 			TriggerEvent("setPlateEveryone",vehicle[1].plate)
				-- 		end
				-- 	else
				-- 		TriggerClientEvent("Notify",source,"error","Dinheiro insuficiente.",5000)
				-- 	end
				-- else
					local status,vehid = vCLIENT.spawnVehicle(source,name,vehicle[1].plate,vehicle[1].engine,vehicle[1].body,vehicle[1].fuel,custom,vehicle[1].windows,vehicle[1].doors,vehicle[1].tyres)
					if status then
						vehlist[vehid] = { parseInt(user_id),name }
						--print(vehid)
						vehSpawn[vehPlate] = { parseInt(user_id),name,vehid }
						spanwedVehs[name..user_id] = true

						TriggerEvent("setPlateEveryone",vehicle[1].plate)
						
					end
				--end

				if name == "stockade" then
					TriggerEvent("vrp_stockade:inputVehicle",vehicle[1].plate)
				end
			end
		--else
		--	TriggerClientEvent("Notify",source,"info","Você já tem um veículo deste modelo fora da garagem.",5000)
		--end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.createVehicle(mHash,x,y,cdz,h,vehPlate,vehBody,vehDoors)
	spawnVehicle = 0
	local myVeh = CreateVehicle(mHash,x+0.0,y+0.0,cdz,h+0.0,true,true)
	while not DoesEntityExist(myVeh) and spawnVehicle <= 1000 do
		spawnVehicle = spawnVehicle + 1
		Citizen.Wait(100)
	end

	if DoesEntityExist(myVeh) then
		if vehPlate ~= nil then
			SetVehicleNumberPlateText(myVeh,vehPlate)
		else
			vehPlate = vRP.generatePlate()
			SetVehicleNumberPlateText(myVeh,vehPlate)
		end

		-- SetVehicleBodyHealth(myVeh,vehBody + 0.0)

		if vehDoors then
			local vehDoors = json.decode(vehDoors)
			if vehDoors ~= nil then
				for k,v in pairs(vehDoors) do
					if v then
						SetVehicleDoorBroken(myVeh,parseInt(k),true)
					end
				end
			end
		end
		
		local netVeh = NetworkGetNetworkIdFromEntity(myVeh)

		return netVeh
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.deleteVehicles()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local vehicle = vRPclient.getNearVehicle(source,15)
		if vehicle then
			vCLIENT.deleteVehicle(source,vehicle)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DV
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("dv",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"Admin") then
		local vehicle = vRPclient.getNearVehicle(source,15)
		if vehicle then
			vCLIENT.deleteVehicle(source,vehicle)
		end
	end
end)


RegisterServerEvent("garages:DeletarVeiculo")
AddEventHandler("garages:DeletarVeiculo",function()
	local user_id = vRP.getUserId(source)
	local vehicle = vRPclient.getNearVehicle(source,15)
	if vehicle then
		vCLIENT.deleteVehicle(source,vehicle)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FGARAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("rgarage",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"Admin") then
		spanwedVehs[args[1]..args[2]] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLELOCK
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.vehicleLock()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local vehicle,vehNet,vehPlate,vehName,vehLock = vRPclient.vehList(source,11)
		if vehicle and vehPlate then
			local plateUserId = vRP.getVehiclePlate(vehPlate)
			if user_id == plateUserId or stealVehs[vehPlate] == user_id then
				TriggerClientEvent("garages:vehicleClientLock",-1,vehNet,vehLock)

				if vehLock == 1 then
					TriggerClientEvent("Notify",source,"unlock","Veículo destrancado.",5000)
					TriggerClientEvent("sounds:source",source,"unlock",0.5)
				else
					TriggerClientEvent("Notify",source,"lock","Veículo trancado.",5000)
					TriggerClientEvent("sounds:source",source,"lock",0.5)
				end

				if not vRPclient.inVehicle(source) then
					vRPclient.playAnim(source,true,{"anim@mp_player_intmenu@key_fob@","fob_click"},false)
					Citizen.Wait(500)
					vRPclient.stopAnim(source)
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.tryDelete(vehid,vehengine,vehbody,vehfuel,vehDoors,vehWindows,vehTyres,vehPlate)
	local source = source
	if vehlist[vehid] and vehid ~= 0 then
		local user_id = vehlist[vehid][1]
		local vehname = vehlist[vehid][2]

		local player = vRP.getUserSource(user_id)
		if player then
			vCLIENT.syncNameDelete(player,vehname)
		end

		if parseInt(vehengine) <= 100 then
			vehengine = 100
		end

		if parseInt(vehbody) <= 100 then
			vehbody = 100
		end

		if parseInt(vehfuel) >= 100 then
			vehfuel = 100
		end

		if parseInt(vehfuel) <= 5 then
			vehfuel = 5
		end

		local vehicle = vRP.query("vRP/get_vehicles",{ user_id = parseInt(user_id), vehicle = tostring(vehname) })
		if vehicle[1] ~= nil then
			spanwedVehs[vehname..user_id] = nil
			vRP.execute("vRP/set_update_vehicles",{ user_id = parseInt(user_id), vehicle = tostring(vehname), engine = parseInt(vehengine), body = parseInt(vehbody), fuel = parseInt(vehfuel), doors = json.encode(vehDoors), windows = json.encode(vehWindows), tyres = json.encode(vehTyres) })
		end

		if vehSignal[vehPlate] then
			vehSignal[vehPlate] = nil
		end
	
		if vehSpawn[vehPlate] then
			vehSpawn[vehPlate] = nil
		end

		if vehlist[vehid] then
			vehlist[vehid] = nil
		end
	end

	TriggerClientEvent("garages:syncVehicle",-1,vehid,vehPlate)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- garages:DELETEVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:DeleteVehicle")
AddEventHandler("garages:DeleteVehicle",function(vehid,vehPlate)
	TriggerClientEvent("garages:syncVehicle",-1,vehid,vehPlate)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNHOUSES
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.returnHouses(garage)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if not vRP.wantedReturn(user_id) then

			local spawns = vRP.query("select_table_garage_spawns", { idGaragem = garage.id}) 
						
			if garage.perm ~= "public" then
				if vRP.hasPermission(user_id,garage.perm) then
					return vCLIENT.openGarage(source,garage,spawns)
				end
			else
				local getFines = vRP.getFines(user_id)
				if getFines[1] then
					TriggerClientEvent("Notify",source,"info","Você tem multas pendentes.",5000)
					return false
				end

				return vCLIENT.openGarage(source,garage,spawns)
			end
		end
		return false
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("car",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
 	if user_id then
		if vRP.hasPermission(user_id,"Admin") and args[1] then
      		local plate = "55DTA141"
			TriggerClientEvent("adminVehicle",source,args[1],plate)
      		TriggerEvent("setPlateEveryone",plate)
			TriggerEvent("setPlatePlayers",plate,user_id)
			--SendWebhookMessage(webhookcar,"```prolog\n[ID]: "..user_id.."\n[SPAWNOU CARRO]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
			local embed = {{
				["color"] = 15158332,
				["title"] = "Spawnou um Veiculo",
				["thumbnail"] = { ["url"] = "http://191.101.131.14/carros/"..tostring(args[1])..".png" },
				["fields"] = {
					{
						["name"] = "Quem Spawnou ",
						["value"] = "```[Nome] : "..identity.name.." "..identity.name2.." \n[ID]: "..user_id.." ```",
					},
					{
						["name"] = "Carro Spawnado",
						["value"] = "```[ITEM] : "..args[1].."```",
					}
				},
				["footer"] = {
					["text"] = "CPX_DZ7_LOGs",
					["icon_url"] = "https://media.discordapp.net/attachments/1079273112677404682/1079273335961157753/logo.png?width=559&height=559",
				}
			}}
			SendWebhook(webhookcar,embed)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("vehs",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		if args[1] == "transfer" and parseInt(args[3]) > 0 then
			local myvehicles = vRP.query("vRP/get_vehicles",{ user_id = parseInt(user_id), vehicle = tostring(args[2]) })
			if myvehicles[1] then
				local maxVehs = vRP.query("vRP/con_maxvehs",{ user_id = parseInt(args[3]) })
				local myGarages = vRP.getInformation(args[3])
				if vRP.getPremium(parseInt(args[3])) then
					if parseInt(maxVehs[1].qtd) >= parseInt(myGarages[1].garage) then
						TriggerClientEvent("Notify",source,"info","Você atingiu o número máximo de veículos na garagem.",5000)
						return
					end
				else
					if parseInt(maxVehs[1].qtd) >= parseInt(myGarages[1].garage) then
						TriggerClientEvent("Notify",source,"info","Você atingiu o número máximo de veículos na garagem.",5000)
						return
					end
				end

				local identity = vRP.getUserIdentity(parseInt(args[3]))
				if vRP.request(source,"Deseja transferir o veículo <b>"..vRP.vehicleName(tostring(args[2])).."</b> para <b>"..identity.name.."</b>?",30) then
					local vehicle = vRP.query("vRP/get_vehicles",{ user_id = parseInt(args[3]), vehicle = tostring(args[2]) })
					if vehicle[1] then
						TriggerClientEvent("Notify",source,"error","<b>"..identity.name.."</b> já possui este veículo.",5000)
					else
						vRP.execute("vRP/move_vehicle",{ user_id = parseInt(user_id), nuser_id = parseInt(args[3]), vehicle = tostring(args[2]) })

						local custom = vRP.getSData("custom:"..parseInt(user_id)..":"..tostring(args[2]))
						local custom2 = json.decode(custom) or {}
						if custom and custom2 ~= nil then
							vRP.setSData("custom:"..parseInt(args[3])..":"..tostring(args[2]),json.encode(custom2))
							vRP.execute("vRP/rem_srv_data",{ dkey = "custom:"..parseInt(user_id)..":"..tostring(args[2]) })
						end

						local chest = vRP.getSData("chest:"..parseInt(user_id)..":"..tostring(args[2]))
						local chest2 = json.decode(chest) or {}
						if chest and chest2 ~= nil then
							vRP.setSData("chest:"..parseInt(args[3])..":"..tostring(args[2]),json.encode(chest2))
							vRP.execute("vRP/rem_srv_data",{ dkey = "chest:"..parseInt(user_id)..":"..tostring(args[2]) })
						end

						TriggerClientEvent("Notify",source,"check","Transferência concluída com sucesso.",5000)
					end
				end
			end
		else
			local vehicle = vRP.query("vRP/get_vehicle_users",{ user_id = parseInt(user_id) })
			for k,v in ipairs(vehicle) do
				local nome = vRP.vehicleName(v.vehicle)
				if nome == nil then
					nome = "sem nome"
				end
			
				TriggerClientEvent("Notify",source,"info","<b>Modelo:</b> "..nome.." ( "..v.vehicle.." )",10000)
				Citizen.Wait(1)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function cnVRP.returnVehicle(name,user_id)
	return spanwedVehs[name..user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHSIGNAL
-----------------------------------------------------------------------------------------------------------------------------------------
exports("vehSignal",function(vehPlate)
	return vehSignal[vehPlate]
end)

local garages_s = nil

Citizen.CreateThread(function()
	while garages_s == nil do
		Citizen.Wait(1000)
		garages_s = vRP.query("select_table_garage", {})
		Citizen.Wait(5000)
	end
end)

function cnVRP.addGaragem(data, spaws)
	local source = source

	local tipo = vRP.prompt(source,"Tipo:","garage")
	local perm = vRP.prompt(source,"Perm:","public")

	data.tipo = tipo
	data.perm = perm

	vRP.execute("insert_table_garage", data)

	Wait(100)

	local rows_garage = vRP.query("select_ult_id_garage", {})
	
	local id_g = rows_garage[1].id

	for k, v in pairs(spaws) do
		v.idGaragem = id_g
		vRP.execute("insert_table_garage_spawn", v)
	end

	TriggerClientEvent("Notify",source,"check","Criado com Sucesso.",20000)

	Wait(250)
	garages_s = vRP.query("select_table_garage", {})
	TriggerClientEvent("garages:atualizarGarages",-1, garages_s)
	
end

function cnVRP.addGaragemCasas(data, spaws, homeName)
	local source = source
	local user_id = vRP.getUserId(source)

	local tipo = "garage"
	local perm = homeName

	data.tipo = tipo
	data.perm = perm

	vRP.execute("insert_table_garage", data)

	Wait(100)

	local rows_garage = vRP.query("select_ult_id_garage", {})
	
	local id_g = rows_garage[1].id

	vRP.execute("insert_table_garage_spawn", { idGaragem = parseInt(id_g), x = tostring(spaws.x), y = tostring(spaws.y), z = tostring(spaws.y), h = tostring(spaws.h) })

	--TriggerClientEvent("Notify",source,"check","Criado com Sucesso.",20000)
	if not vRP.hasPermission(parseInt(user_id),tostring(homeName)) then
		vRP.insertPermission(parseInt(user_id),tostring(homeName))
		vRP.execute("vRP/add_group",{ user_id = parseInt(user_id), permiss = tostring(homeName) })
	end

	Wait(250)
	garages_s = vRP.query("select_table_garage", {})
	TriggerClientEvent("garages:atualizarGarages",-1, garages_s)
	
end

function cnVRP.removeGaragem(data)
	vRP.execute("delete_table_garage_spawn", data)
	vRP.execute("delete_table_garage", data)
	Wait(250)
	garages_s = vRP.query("select_table_garage", {})
	TriggerClientEvent("garages:atualizarGarages",-1, garages_s)
end

function cnVRP.getGaragem()
	return garages_s
end

function cnVRP.permissao()
	local source = source
	local user_id = vRP.getUserId(source)

	if vRP.hasPermission(user_id,"Owner") then 
		return true
	else 
		TriggerClientEvent("Notify",source,"error","Acesso NEGADO.",20000)
		return false
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDisconnect",function(user_id)
	if searchTimers[user_id] then
		searchTimers[user_id] = nil
	end
end)