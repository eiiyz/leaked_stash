ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('cfx_stashes:getStashItem')
AddEventHandler('cfx_stashes:getStashItem', function(owner, type, item, count, currentStash)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(xPlayer.identifier)

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getSharedInventory', currentStash, function(inventory)
			local inventoryItem = inventory.getItem(item)
			if count > 0 and inventoryItem.count >= count then
				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = _U('player_cannot_hold'), length = 5500})
				else
					inventory.removeItem(item, count)
					xPlayer.addInventoryItem(item, count)
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = _U('have_withdrawn', count, inventoryItem.label), length = 7500})
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = _U('not_enough_in_stash'), length = 5500})
			end
		end)

	elseif type == 'item_account' then
		TriggerEvent('esx_addonaccount:getSharedAccount', currentStash..'_'..item, function(account)
			local policeAccountMoney = account.money

			if policeAccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(item, count)
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = _U('have_withdrawn', count, "Black Money"), length = 7500})
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = _U('amount_invalid'), length = 5500})
			end
		end)
	elseif type == 'item_weapon' then
		TriggerEvent('esx_datastore:getSharedDataStore', currentStash, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil
	
			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == item then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo
	
					table.remove(storeWeapons, i)
					break
				end
			end
	
			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)
	end

end)

RegisterServerEvent('cfx_stashes:putStashItem')
AddEventHandler('cfx_stashes:putStashItem', function(owner, type, item, count, currentStash)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(xPlayer.identifier)

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(item).count

		if playerItemCount >= count and count > 0 then
			TriggerEvent('esx_addoninventory:getSharedInventory', currentStash, function(inventory)
				xPlayer.removeInventoryItem(item, count)
				inventory.addItem(item, count)
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = _U('have_deposited', count, inventory.getItem(item).label), length = 7500})
			end)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = "error", text = _U('invalid_quantity'), length = 5500})
		end

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(item).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(item, count)
			TriggerEvent('esx_addonaccount:getSharedAccount', currentStash..'_'..item, function(account)
				account.addMoney(count)
			end)
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = _U('have_deposited', count, "Black Money"), length = 7500})
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = _U('amount_invalid'), length = 5500})
		end

	elseif type == 'item_weapon' then
		TriggerEvent('esx_datastore:getSharedDataStore', currentStash, function(store)
			local storeWeapons = store.get('weapons') or {}
	
			table.insert(storeWeapons, {
				name = item,
				count = count
			})
	
			xPlayer.removeWeapon(item)
			store.set('weapons', storeWeapons)
			
		end)
	end

end)

ESX.RegisterServerCallback('cfx_stashes:getStashInventory', function(source, cb, identifier, currentStash)
	local xPlayer    = ESX.GetPlayerFromIdentifier(identifier)
	local blackMoney = 0
	local items      = {}
	local weapons    = {}
	local stash_name = nil
	
	TriggerEvent('esx_addonaccount:getSharedAccount', currentStash..'_black_money', function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_addoninventory:getSharedInventory', currentStash, function(inventory)
		items = inventory.items
	end)

	TriggerEvent('esx_datastore:getSharedDataStore', currentStash, function(store)
		weapons = store.get('weapons') or {}
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons,
		stash_name = currentStash
	})
end)