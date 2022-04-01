---------------
-- Variables --
---------------

-- World related variables

local ped 
local pos 
local obj

-- Data variables 

local shots
local prop = GetHashKey('ind_prop_firework_01')

-- State related variables

local equipped = false

-- Buffer memory loading functions

LoadAnim = function(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		
		Citizen.Wait(1)
	end
end

LoadModel = function(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		
		Citizen.Wait(1)
	end
end

LoadFx = function(str)
	while not HasNamedPtfxAssetLoaded(str) do
		RequestNamedPtfxAsset(str)

		Citizen.Wait(1)
	end
end

-- GFX Scaleform related functions

function hintToDisplay(text, bool)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, bool, -1)
end

function subtitle(message)
	SetTextEntry_2("STRING")
	AddTextComponentString(message)
	EndTextCommandPrint(25, 1)
end

----------
-- Code --
----------

-- Main loop : get a key input and update the firework mortar state

Citizen.CreateThread(function()

	RegisterCommand('firework', function()
		if not equipped then 
			-- Load the needed elements

			LoadModel(prop)
			LoadAnim("combat@gestures@gang@pistol_1h@beckon")

			-- Use the loaded elements
		
			obj = CreateObject(prop, pos, true, true, false)										
			TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", '0', 8.0, -8.0, -1, 50, 0.0, 0, 0, 0)
			AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped,  28422), 0.4, 0.05, 0.11, 0.0, 75.0, 10.0, 0, false, false, true, false, 2, true)
			shots = 5
			equipped = true
		else 
			-- Clear all the actions 

			ClearPedTasks(ped)
			DeleteEntity(obj)
			obj = nil 
			shots = 0 
			equipped = false
		end
	end, false)

	while true do	
		ped = PlayerPedId()
		pos = GetEntityCoords(ped)

		if equipped then 

			-- Tick looped actions 

			if not IsEntityAttachedToEntity(obj, ped) then
				AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped,  28422), 0.4, 0.05, 0.11, 0.0, 75.0, 10.0, 0, false, false, true, false, 2, true)
			end

			if not IsEntityPlayingAnim(ped, "combat@gestures@gang@pistol_1h@beckon", '0', 3) then 
				TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", '0', 8.0, -8.0, -1, 50, 0.0, 0, 0, 0)
			end 

			DisableControlAction(0, cfg.key, true)
			subtitle(shots..' left in the mortar')
			hintToDisplay('Press '..cfg.keyName..' to shoot')

			-- Waiting for an input

			if IsDisabledControlJustPressed(0, cfg.key) then
				if shots > 0 then 
					shoot()
				else 
					hintToDisplay('~r~You dont have enough fireworks')
					ExecuteCommand('firework')
				end
			end

		else 
			EnableControlAction(0, cfg.key, true)
		end

		Citizen.Wait(3)
	end
end)

-- Function Shoot : send a trigger for a synced shoot across the server

function shoot()
	TriggerServerEvent("fwmortar:server:shoot")
	shots = shots - 1
end

------------
-- Events --
------------

-- Event "fwmortar:client:fx" : Get a net entity (ped) and create a firework effect from it

RegisterNetEvent("fwmortar:client:fx")
AddEventHandler("fwmortar:client:fx", function(netId)
	target = GetPlayerPed(GetPlayerFromServerId(netId))

	-- Load fx 

	LoadFx('scr_indep_fireworks')
	UseParticleFxAsset('scr_indep_fireworks')
	StartParticleFxNonLoopedOnEntity('scr_indep_firework_shotburst', target, 0.0, 0.0, 0.8, 90.0, 0.0, 173.0, 0.4, false, false, false)
	UseParticleFxAsset('scr_indep_fireworks')
	StartParticleFxNonLoopedOnEntity('scr_indep_firework_trailburst', target, 0.0, 0.0, 0.6, 90.0, 0.0, 177.0, 0.7, false, false, false)
	local offset = GetOffsetFromEntityInWorldCoords(target, 0.0, 12.0, 0.0)
	Wait(900)
	LoadFx('proj_xmas_firework')
	UseParticleFxAsset('proj_xmas_firework')
	StartParticleFxNonLoopedOnEntity('scr_firework_xmas_repeat_burst_rgw', target, 0.0, 12.0, 0.8, 0.0, 0.0, 0.0, 0.3, false, false, false)

	-- Create some fire

	if Vdist(pos, offset) < 2.0 then 
		StartEntityFire(ped)
		PlayPain(ped, 8, 0)
	end
	StartScriptFire(offset.x, offset.y, offset.z - 1.0, 2, false)
end)
