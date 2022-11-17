local QBCore = exports['qb-core']:GetCoreObject()
isCreatingGang = false
hasStash = false
hasGarage = false
gang = nil
name = nil
label = nil

RegisterNetEvent("qb-gangs:client:BeginGangCreation")
AddEventHandler("qb-gangs:client:BeginGangCreation", function(gangName, gangLabel)
    name = gangName
    label = gangLabel
    gang = {
        ["VehicleSpawner"] = {},
        ["Stash"] = {}
    }
    isCreatingGang = true
    TriggerEvent("chatMessage", "SYSTEM", "warning", "Új banda: "..gangName.."létrehozva, használd a /placestash, /placegarage,  /finishgang or /cancelgang")
end)

RegisterCommand("placestash", function()
    if isCreatingGang then
        if not hasStash then
            local plyCoords = GetEntityCoords(PlayerPedId())
            
            gang["Stash"] = {
                label = name.." Stash",
                coords = {x = plyCoords.x, y = plyCoords.y, z = plyCoords.z, h = GetEntityHeading(PlayerPedId())}    
            }

            hasStash = true
            QBCore.Functions.Notify("Banda tároló lerakva", "success")
        else
            QBCore.Functions.Notify("Tároló már le van rakva te vasz", "error")
        end
    else
        QBCore.Functions.Notify("Nem nem csinálsz bandát!", "error")
    end
end)

RegisterCommand("placegarage", function()
    if isCreatingGang then
        if not hasGarage then
            -- NUI To handle colour picker and vehicle selection
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open"
            })
        else
            QBCore.Functions.Notify("Már leraktál egy banda garázst!", "error")
        end
    else
        QBCore.Functions.Notify("Te nem készítesz bandát!", "error")
    end
end)

RegisterCommand("finishgang", function()
    if isCreatingGang then
        if hasGarage and hasStash then
            TriggerServerEvent("qb-gangs:server:creategang", gang, name, label)
            gang = nil
            hasGarage, hasStash = false, false
        else
            QBCore.Functions.Notify("Nem fejezted még be!", "error")
        end
    else
        QBCore.Functions.Notify("Te nem készítesz bandát!", "error")
    end
end)

RegisterCommand("cancelgang", function()
    if isCreatingGang then
        isCreatingGang, hasGarage, hasStash = false, false, false
        gang, name, label = nil, nil, nil
    else
        QBCore.Functions.Notify("Te nem készítesz bandát!", "error")
    end
end)

RegisterNUICallback("SetVehicleColour", function(data, cb)
    SetNuiFocus(false, false)
    -- Recieve arrays for colours and vehicles, js handlers spliting into arrays
    local primary = data.primary
    local secondary = data.secondary
    local vehicleList = data.vehicleList

    print(json.encode(vehicleList))

    local coords = GetEntityCoords(PlayerPedId())
    
    gang["VehicleSpawner"] = {
        label = "Car Spawn",
        coords = {x = coords.x, y = coords.y, z = coords.z, h = GetEntityHeading(PlayerPedId())},
        colours = {
            ["primary"] = {
                r = tonumber(primary[1]),
                g = tonumber(primary[2]), 
                b = tonumber(primary[3])
            },
            ["secondary"] = { 
                r = tonumber(secondary[1]),
                g = tonumber(secondary[2]), 
                b = tonumber(secondary[3])
            },
        },
        vehicles = {}
    }

    -- Iterate through vehicles array, check they are valid and insert into gang vehicles
    for k, v in pairs(vehicleList) do
        if QBCore.Shared.Vehicles[v] ~= nil then
            local name = QBCore.Shared.Vehicles[v].name
            gang["VehicleSpawner"]["vehicles"][v] = name
        else
            QBCore.Functions.Notify(v.." nem létezik a jármű  a qb-core/shared-modules/vehicles.lua fájlban! Szólj egy fejlesztőnek vagy tulajdonosknak!", "error")
        end
    end

    hasGarage = true
    QBCore.Functions.Notify("Garázs lerakva!", "success")

    cb("200 - OK")
end)

RegisterNUICallback("CloseMenu", function(source, cb)
    SetNuiFocus(false, false)

    cb("200 - OK")
end)