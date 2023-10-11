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
vCLIENT = Tunnel.getInterface("pressurewasher")

-- ESX = nil

-- TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function studiodz7.payment(source)
	local source = source
	local user_id = vRP.getUserId(source)
	print(source)

	print(user_id)
	if vRP.paymentBank(user_id,500) then
		return true
	else
		return false
	end
end



