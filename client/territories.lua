local QBCore = exports['qb-core']:GetCoreObject()
local Territories = {}
local insidePoint = false
local activeZone = nil
local loaded = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    loaded = true
    print('[gangsystem]: Betöltésre kerülnek a területek!')
end)



--DEV RESI STB FASZSÁG
--AddEventHandler('onResourceStart', function(resourceName)
   -- loaded = true
   -- print('[gangsystem]: Betöltésre kerülnek a területek!')
--end)



Citizen.CreateThread(function()
    Citizen.Wait(500)
    for k, v in pairs(Zones["Territories"]) do
        local zone = CircleZone:Create(v.centre, v.radius, {
            name = "greenzone-"..k,
            debugPoly = Zones["Config"].debug,
        })

        local blip = AddBlipForRadius(v.centre.x, v.centre.y, v.centre.z, v.radius)
        SetBlipAlpha(blip, 80) -- Change opacity here
        SetBlipColour(blip, Zones["Colours"][v.winner] ~= nil and Zones["Colours"][v.winner] or Zones["Colours"].neutral)
    
        Territories[k] = {
            zone = zone,
            id = k,
            blip = blip
        }
    end
end)

RegisterNetEvent("qb-gangs:client:updateblips")
AddEventHandler("qb-gangs:client:updateblips", function(zone, winner)
    local colour = Zones["Colours"][winner]
    local blip = Territories[zone].blip

    SetBlipColour(blip, colour)
end)

Citizen.CreateThread(function()
    while loaded==true do 
        Citizen.Wait(500)
        if PlayerGang.name ~= "none" or PlayerJob.name == "police" then
            local PlayerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(PlayerPed)

            for k, zone in pairs(Territories) do
                if Territories[k].zone:isPointInside(pedCoords) then
                    insidePoint = true
                    activeZone = Territories[k].id
                    
                    TriggerEvent("QBCore:Notify", "Beléptél Banda területre", "success")

                    -- Whilst inside the zone we send a server event for the server sided calculations
                    while insidePoint == true do
                        TriggerServerEvent("qb-gangs:server:updateterritories", activeZone, true)

                        -- We fetch a callback for the most reason status of the zone and send it to the NUI
                        QBCore.Functions.TriggerCallback("qb-gangs:server:getstatus", function(status, gang, score)
                        print('1 '..status)
                        print('2 '..gang)
                        print('3 '..score)
                        exports['ps-ui']:DisplayText("<b>Banda Terület</p>Befoglalás: "..score.."%</p> Tulajdonos:"..gang.."</p>Státusz: "..status.."", "warning") -- Colors: primary, error, success, warning, info, mint
                        end, activeZone)

                        if not Territories[k].zone:isPointInside(GetEntityCoords(PlayerPed)) then
                            TriggerServerEvent("qb-gangs:server:updateterritories", activeZone, false)

                            insidePoint = false
                            activeZone = nil

                            QBCore.Functions.Notify("Kiléptél banda területről", "error")

                            Citizen.Wait(1000)

                            exports['ps-ui']:HideText()
                        end

                        Citizen.Wait(1000)
                    end
                end
            end
        else
            Citizen.Wait(2000)
        end
    end
end)
