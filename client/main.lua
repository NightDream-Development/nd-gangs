local QBCore = exports['qb-core']:GetCoreObject() --Új Qbcore
Config = {}

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
        Citizen.Wait(100) 
    end

    QBCore.Functions.TriggerCallback("qb-gangs:server:FetchConfig", function(gangs)
        Config.Gangs = gangs
    end)
end)

RegisterNetEvent("qb-gangs:client:UpdateGangs")
AddEventHandler("qb-gangs:client:UpdateGangs", function(gangs)
    Config.Gangs = gangs
end)

isLoggedIn = false
PlayerGang = {}
PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerGang = QBCore.Functions.GetPlayerData().gang
    PlayerJob = QBCore.Functions.GetPlayerData().job
    QBCore.Functions.Notify('Banda: Betöltés készen van!', infrom)
end)

--DEV RESI STB FASZSÁG
AddEventHandler('onResourceStart', function(resourcename)
    QBCore.Functions.TriggerCallback("qb-gangs:server:FetchConfig", function(gangs)
        Config.Gangs = gangs
    end)
    Wait(1500)
    isLoggedIn = true
    PlayerGang = QBCore.Functions.GetPlayerData().gang
    PlayerJob = QBCore.Functions.GetPlayerData().job
    print('[gangsystem]: CP-k betöltés!')
end)


RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerGang = GangInfo
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(JobInfo)
    PlayerJob = JobInfo
    isLoggedIn = true
end)

local currentAction = "none"

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isLoggedIn and PlayerGang.name ~= "none" then
        	if Config.Gangs[PlayerGang.name] ~= nil then
	            v = Config.Gangs[PlayerGang.name]["Stash"]

	            ped = PlayerPedId()
	            pos = GetEntityCoords(ped)

	            stashdist = #(pos - vector3(v["coords"].x, v["coords"].y, v["coords"].z))
	            if stashdist < 5.0 then
	                DrawMarker(2, v["coords"].x, v["coords"].y, v["coords"].z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
	                if stashdist < 1.5 then
	                    QBCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "[~g~E~w~] - Tároló")
	                    currentAction = "stash"
	                elseif stashdist < 2.0 then
	                    QBCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "Tároló")
	                    currentAction = "none"
	                end
	            else
	                Citizen.Wait(1000)
	            end
	        end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isLoggedIn and PlayerGang.name ~= "none" then
        	if Config.Gangs[PlayerGang.name] ~= nil then
	            v = Config.Gangs[PlayerGang.name]["VehicleSpawner"]
	            ped = PlayerPedId()
	            pos = GetEntityCoords(ped)

	            vehdist = #(pos - vector3(v["coords"].x, v["coords"].y, v["coords"].z))

	            if vehdist < 5.0 then
	                DrawMarker(2, v["coords"].x, v["coords"].y, v["coords"].z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 10, 50, 200, 222, false, false, false, true, false, false, false)
	                if vehdist < 1.5 then
	                    QBCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "[~g~E~w~] - Garázs")
	                    currentAction = "garage"
	                elseif vehdist < 2.0 then
	                    QBCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "Garázs")
	                    currentAction = "none"
	                end
	                
	                Menu.renderGUI()
	            else
	                Citizen.Wait(1000)
	            end
	        end
        else
            Citizen.Wait(2500)
        end
    end
end)

RegisterCommand("+GangInteract", function()
    if currentAction == "stash" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", PlayerGang.name.."tároló", {
            maxweight = 4000000,
            slots = 500,
        })
        TriggerEvent("inventory:client:SetCurrentStash", PlayerGang.name.."tároló")
    elseif currentAction == "garage" then
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            DeleteVehicle(GetVehiclePedIsIn(GetPlayerPed(-1)))
        else
            GangGarage()
            Menu.hidden = not Menu.hidden
        end
    end
end, false)
RegisterCommand("-GangInteract", function()
end, false)
TriggerEvent("chat:removeSuggestion", "/+GangInteract")
TriggerEvent("chat:removeSuggestion", "/-GangInteract")

RegisterKeyMapping("+GangInteract", "Banda menü interakció", "keyboard", "e")

function GangGarage()
    MenuTitle = "Garázs"
    ClearMenu()
    Menu.addButton("Járművek", "VehicleList", nil)
    Menu.addButton("Menü bezárása", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    MenuTitle = "Jármű:"
    ClearMenu()
    Vehicles = Config.Gangs[PlayerGang.name]["VehicleSpawner"]["vehicles"]
    for k, v in pairs(Vehicles) do
        Menu.addButton(Vehicles[k], "TakeOutVehicle", k, "Garázs", " Motor: 100%", " Karosszéria: 100%", " Üzemanyag: 100%")
    end
        
    Menu.addButton("Vissza", "GangGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        local v = Config.Gangs[PlayerGang.name]["VehicleSpawner"]
        local coords = v.coords
        local primary = v["colours"]["primary"]
        local secondary = v["colours"]["secondary"]
        SetVehicleCustomPrimaryColour(veh, primary.r, primary.g, primary.b)
        SetVehicleCustomSecondaryColour(veh, secondary.r, secondary.g, secondary.b)
        SetEntityHeading(veh, coords.h)
        exports['ps-fuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    Menu.hidden = true
    ClearMenu()
end
