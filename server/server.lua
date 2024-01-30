local QBCore = exports['qb-core']:GetCoreObject()

function saveData(src, charInfo)
    local Player = QBCore.Functions.GetPlayer(src)
	Player.Functions.SetPlayerData("charinfo", charInfo)
	Player.Functions.SetMetaData("firstname", charInfo.firstname)
	Player.Functions.SetMetaData("lastname", charInfo.lastname)

	Player.Functions.Save()
	Player.Functions.UpdatePlayerData(false)
	TriggerClientEvent('QBCore:Player:UpdatePlayerData', src)

end

function ReceivedName(Player, submittedfirstname, submittedlastname)
	if not Player then print("Player not found!") return end
	local charInfo = Player.PlayerData.charinfo
	if Config.debugprints then print("Received Data from Client | firstname: ", submittedfirstname, " | lastname: ", submittedlastname) end
	charInfo.firstname = charInfo.firstname ~= '' and submittedfirstname
	charInfo.lastname = charInfo.lastname ~= '' and submittedlastname

	saveData(source, charInfo)

	if Config.debugprints then print("Player Name Changed To | ", charInfo.firstname, " | ", charInfo.lastname) end
end

function notifyPlayer(src, msg, status)
	if Config.ox_lib then
		print("Ox Lib")
	else
		TriggerClientEvent('QBCore:Notify', src, msg, status)
	end
end

RegisterNetEvent("MrNewbNameChanger:change", function(submittedfirstname, submittedlastname)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local item = Config.namechangeitem

	if not Player then print("Player not found!") return end

	if Config.ox_inv then
	    local items = exports.ox_inventory:Search(src, 'count', item)
		if items >= 1 then
			ReceivedName(Player, submittedfirstname, submittedlastname)
			exports.ox_inventory:RemoveItem(src, item, 1)
		end
	else
		local namechangeitem = Player.Functions.GetItemByName(item)
		if namechangeitem ~= nil then
			ReceivedName(Player, submittedfirstname, submittedlastname)
			Player.Functions.RemoveItem(item, 1)
		end
	end
end)

RegisterNetEvent("MrNewbNameChanger:metaItem", function(submittedfirstname, submittedlastname)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local item = Config.marriagecertificate
	local filleditem = Config.filledcertificate

	if not Player then print("Player not found!") return end

	if Config.ox_inv then
	    local items = exports.ox_inventory:Search(src, 'count', item)
		if items >= 1 then
			exports.ox_inventory:RemoveItem(src, item, 1)
			local metadata = { firstname = submittedfirstname, lastname = submittedlastname,
				description = "Certificate for legal name change to "..submittedfirstname.."  "..submittedlastname 
			}
			exports.ox_inventory:AddItem(src, filleditem, 1, metadata)
		end
	else
		local namechangeitem = Player.Functions.GetItemByName(item)
		if namechangeitem ~= nil then
			Player.Functions.RemoveItem(item, 1)
			local info = { firstname = submittedfirstname, lastname = submittedlastname, }
			Player.Functions.AddItem(filleditem, 1, nil, info)
			print(info)
			notifyPlayer(src, 'Successfully Created Certificate for '..submittedfirstname.."  "..submittedlastname, 'success')
		end
	end
end)

QBCore.Functions.CreateUseableItem(Config.filledcertificate, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local charInfo = Player.PlayerData.charinfo
    if not Player then print("Player not found!") return end
	
	if Config.ox_inv then
		charInfo.firstname = charInfo.firstname ~= '' and item.metadata.firstname
		charInfo.lastname = charInfo.lastname ~= '' and item.metadata.lastname
		
		saveData(src, charInfo)
		
		exports.ox_inventory:RemoveItem(src, item, 1)
		
		if Config.debugprints then print("Player Name Changed To | ", charInfo.firstname, " | ", charInfo.lastname) end
	else
		charInfo.firstname = charInfo.firstname ~= '' and item.info.firstname
		charInfo.lastname = charInfo.lastname ~= '' and item.info.lastname
		
		saveData(src, charInfo)
		
		Player.Functions.RemoveItem(item, 1)
		
		if Config.debugprints then print("Player Name Changed To | ", charInfo.firstname, " | ", charInfo.lastname) end
	end
end)

QBCore.Functions.CreateUseableItem(Config.namechangeitem, function(source, item)
    TriggerClientEvent('newbsnamechange:client:openName', source, false)
end)

QBCore.Functions.CreateUseableItem(Config.marriagecertificate, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

	if Config.jobcheck then
		if not Player.PlayerData.job.name == Config.jobname then return end
		TriggerClientEvent('newbsnamechange:client:openName', src, true)
	else
		TriggerClientEvent('newbsnamechange:client:openName', src, false)
	end

end)
