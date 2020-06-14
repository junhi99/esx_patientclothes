local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local menuIsShowed				  = false
local hasAlreadyEnteredMarker     = false
local lastZone                    = nil
local isInhospitallistingMarker   = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenBajuMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = 'Lemari Baju',
		align    = 'top-left',
		elements = {
			{label = _U('baju_pasien'),     value = 'baju_pasien'},
			{label = "Baju Warga", value = 'citizen_wear'}
	}}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			onDuty = false
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'baju_pasien' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, skinrs)
				if skin.sex == 0 then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 6, 0, 0)--lengan
					SetPedComponentVariation(GetPlayerPed(-1), 4, 65, 0, 0)--celena
					SetPedComponentVariation(GetPlayerPed(-1), 6, 6, 0, 0)--shoes
					SetPedComponentVariation(GetPlayerPed(-1), 11, 144, 0, 0)--torso --nativereference "https://runtime.fivem.net/doc/natives/?_0x262B14F48D29DE80"
					SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 0)--tshirt
				elseif skin.sex == 1 then
					SetPedComponentVariation(GetPlayerPed(-1), 3, 7, 0, 0)--arms
					SetPedComponentVariation(GetPlayerPed(-1), 4, 67, 0, 0)--pants
					SetPedComponentVariation(GetPlayerPed(-1), 6, 35, 0, 0)--shoes
					SetPedComponentVariation(GetPlayerPed(-1), 11, 142, 0, 0)--torso
					SetPedComponentVariation(GetPlayerPed(-1), 8, 151, 0, 0)--tshirt
				else
					TriggerEvent('skinchanger:loadClothes', skin, skinrs.skin_female)
				end
				
			end)
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

AddEventHandler('esx_hospitalclothes:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		isInHospitallistingMarker  = false
		local currentZone = nil
		for i=1, #Config.Zones, 1 do
			local Zones = vector3(Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z)
			if #(coords - Zones) < 1.0 then
				isInHospitallistingMarker  = true
				SetTextComponentFormat('STRING')
            	AddTextComponentString(_U('access_hospital_center'))
            	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
		end
		if isInHospitallistingMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end
		if not isInHospitallistingMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_hospitalclothes:hasExitedMarker')
		end
	end
end)



-- Menu Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2)
		if IsControlJustReleased(0, Keys['E']) and isInHospitallistingMarker and not menuIsShowed then
			OpenBajuMenu()
		end
	end
end)

Citizen.CreateThread(function()
	Holograms()
  end)
  
  function Holograms()
	while true do
	  Citizen.Wait(0)			
		-- Lemari Baju x = 318.29, y = -572.05, z = 43.28
	if GetDistanceBetweenCoords( 318.29, -572.05, 43.28, GetEntityCoords(GetPlayerPed(-1))) < 2.0 then
	  Draw3DText( 318.29, -572.05, 43.28  -1.800, "Tekan [~g~E~w~] untuk membuka lemari pakaian ", 4, 0.1, 0.1)	
	end			
  end
  end
  
  function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
  local scale = (1/dist)*10
  local fov = (1/GetGameplayCamFov())*100
  local scale = scale*fov   
  SetTextScale(scaleX*scale, scaleY*scale)
  SetTextFont(fontId)
  SetTextProportional(1)
  SetTextColour(250, 250, 250, 255)		-- You can change the text color here
  SetTextDropshadow(1, 0, 0, 0, 0.486)
  SetTextEdge(2, 0, 0, 0, 150)
  SetTextDropShadow(0, 0, 0, 0.486)
  SetTextOutline()
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(textInput)
  SetDrawOrigin(x,y,z+2, 0)
  DrawText(0.0, 0.0)
  ClearDrawOrigin()
  end
