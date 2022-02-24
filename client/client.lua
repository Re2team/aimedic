local QBCore = exports['qb-core']:GetCoreObject()

local Active = false
local ambulanceVehicle = nil
local driverPed = nil
local spam = true

local intheHospitalWay=false

 


RegisterCommand("medic", function(source, args, raw)
	if (QBCore.Functions.GetPlayerData().metadata["isdead"]) or (QBCore.Functions.GetPlayerData().metadata["inlaststand"]) and spam then
		QBCore.Functions.TriggerCallback('aimedic:docOnline', function(EMSOnline, hasEnoughMoney)
			if EMSOnline <= Config.Doctor and hasEnoughMoney and spam then
				SpawnVehicle(GetEntityCoords(PlayerPedId()))
				TriggerServerEvent('aimedic:charge')
				Notify("Your medic is on the way")
			else
				if EMSOnline > Config.Doctor then
					Notify("There are too many EMT's online", "error")
				elseif not hasEnoughMoney then
					Notify("Not Enough Money", "error")
				else
					Notify("Wait EMT's are on the Way", "primary")
				end	
			end
		end)
	else
		Notify("This can only be used in last stand", "error")
	end
end)



function SpawnVehicle(x, y, z)  
	spam = false
	local vehhash = GetHashKey("ambulance")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	RequestModel('s_m_m_doctor_01')
	while not HasModelLoaded('s_m_m_doctor_01') do
		Wait(1)
	end
	local spawnRadius = 40                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)

	if not DoesEntityExist(vehhash) then
        mechVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(mechVeh)
		SetVehicleNumberPlateText(mechVeh, "aimedic")
		SetEntityAsMissionEntity(mechVeh, true, true)
		SetVehicleEngineOn(mechVeh, true, true, false)
        
        mechPed = CreatePedInsideVehicle(mechVeh, 26, GetHashKey('s_m_m_doctor_01'), -1, true, false)              	
        
        mechBlip = AddBlipForEntity(mechVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)


		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(mechPed, mechVeh, loc.x, loc.y, loc.z, 80.0, 0, GetEntityModel(mechVeh), 524863, 2.0)
		SetVehicleSiren(mechVeh,true);
		ambulanceVehicle = mechVeh
		driverPed = mechPed
		Active = true
    end
end

   

Citizen.CreateThread(function()
	local mdBoxZone=PolyZone:Create({
		vector2(298.06692504882, -581.3480834961),
		vector2(289.25625610352, -579.44018554688),
		vector2(283.44482421875, -595.53747558594),
		vector2(292.4313659668, -597.95672607422)
	  }, {
		name="MDNPC REVIVE",
		minZ = 41.98,
		maxZ = 45.98,
		debugPoly=true
	  })
    local insidePinkCage = false
	mdBoxZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
		if isPointInside and intheHospitalWay then
			TriggerEvent("hospital:client:npcHospital")
			RemovePedElegantly(driverPed)
			DeleteEntity(ambulanceVehicle)
			spam = true
			intheHospitalWay=false
		end
	end)

    local mdPaletoZone=PolyZone:Create({
  		vector2(-228.0418395996, 6326.7231445312),
  		vector2(-231.95545959472, 6322.9194335938),
  		vector2(-245.10649108886, 6336.1669921875),
  		vector2(-241.05587768554, 6339.8071289062)
	}, {
  		name="MDPalletoNPC",
  		minZ = 29.99,
  		maxZ = 37.13,
		debugPoly=true
	})
    mdPaletoZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
		if isPointInside and intheHospitalWay then
			TriggerEvent("hospital:client:npcHospital")
			RemovePedElegantly(driverPed)
			DeleteEntity(ambulanceVehicle)
			spam = true
			intheHospitalWay=false
		end
	end)

end)

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200)
        if Active then
            local loc = GetEntityCoords(GetPlayerPed(-1))
			local lc = GetEntityCoords(ambulanceVehicle)
			local ld = GetEntityCoords(driverPed)
            local dist = Vdist(loc.x, loc.y, loc.z, lc.x, lc.y, lc.z)
			local dist1 = Vdist(loc.x, loc.y, loc.z, ld.x, ld.y, ld.z)
            if dist <= 10 then
				if Active then
					TaskGoToCoordAnyMeans(driverPed, loc.x, loc.y, loc.z, 10.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 1 then 
					Active = false
					ClearPedTasksImmediately(driverPed)
					DoctorNPC()
				end
            end
        end
    end
end)


function DoctorNPC()
	RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Citizen.Wait(1000)
	end

	TaskPlayAnim(driverPed, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	QBCore.Functions.Progressbar("revive_doc", "Check Your Status", Config.ReviveTime, false, false, {
		disableMovement = false,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function()
		ClearPedTasks(driverPed)
		Citizen.Wait(500)
		local ped = PlayerPedId()
        	-- TriggerEvent("hospital:client:Revive")
		local dragger = PlayerPedId()
		SetEntityCoords(driverPed, GetOffsetFromEntityInWorldCoords(dragger, 0.0, 0.45, 0.0))
		AttachEntityToEntity(dragger, driverPed, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		local vehicleCoords = GetEntityCoords(ambulanceVehicle)
		TaskGoToCoordAnyMeans(driverPed, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z-3, 1.0, 0, 0, 786603, 0xbf800000)
		SetPedIntoVehicle(ped, ambulanceVehicle, 2)
		-- TaskEnterVehicle(driverPed,ambulanceVehicle,-1,0,1.0,1)
		
		local tempInd=1
		local tempDis=10000000000
		for index, value in ipairs(Config.mdLocations) do
			local ourLocation = GetEntityCoords(driverPed)
			local distance=CalculateTravelDistanceBetweenPoints(ourLocation.x,ourLocation.y,ourLocation.z,value.x,value.y,value.z);
			if distance<tempDis then
				tempInd=index
				tempDis=distance
			end
		end
		Wait(200)
		local hospitalLocation =Config.mdLocations[tempInd]
		TaskVehicleDriveToCoord(driverPed, ambulanceVehicle, hospitalLocation.x, hospitalLocation.y, hospitalLocation.z, 8gi0.0, 0, GetEntityModel(ambulanceVehicle), 524863, 2.0)
		intheHospitalWay=true
	end)
end


function Notify(msg, state)
    QBCore.Functions.Notify(msg, state)
end


