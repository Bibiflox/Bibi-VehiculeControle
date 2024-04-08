ESX = exports["es_extended"]:getSharedObject()

local clignotantDroit = false
local clignotantGauche = false
local warning = false
----- Fin cligno
local speedControlActive = false
local cruiseSpeed = 0
local prevMaxSpeed = 0
local speedIncrement = 5 -- Variation de vitesse à chaque ajustement
local isIncreasing = false
local isDecreasing = false
local lastChangeTime = 0
local debounceTime = 500 -- Délai de débordement en millisecondes


function ActiverClignotant(vehicle, gauche)
    if DoesEntityExist(vehicle) then
        if gauche then
            clignotantGauche = not clignotantGauche
            SetVehicleIndicatorLights(vehicle, 1, clignotantGauche)
            TriggerEvent('esx:showNotification', clignotantGauche and 'Clignotant gauche activé' or 'Clignotant gauche désactivé')
        else
            clignotantDroit = not clignotantDroit
            SetVehicleIndicatorLights(vehicle, 0, clignotantDroit)
            TriggerEvent('esx:showNotification', clignotantDroit and 'Clignotant droit activé' or 'Clignotant droit désactivé')
        end
        TriggerServerEvent('clignotants:sync', NetworkGetNetworkIdFromEntity(vehicle), gauche, clignotantDroit, clignotantGauche, warning)
    end
end

function ActiverWarning(vehicle)
    if DoesEntityExist(vehicle) then
        warning = not warning
        SetVehicleIndicatorLights(vehicle, 0, warning)
        SetVehicleIndicatorLights(vehicle, 1, warning)
        TriggerServerEvent('clignotants:sync', NetworkGetNetworkIdFromEntity(vehicle), false, clignotantDroit, clignotantGauche, warning)
        TriggerEvent('esx:showNotification', warning and 'Warnings activés' or 'Warnings désactivés')
    end
end

RegisterNetEvent('clignotants:update')
AddEventHandler('clignotants:update', function(netId, gauche, clignotantDroit, clignotantGauche, warning)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        SetVehicleIndicatorLights(vehicle, 0, clignotantDroit)
        SetVehicleIndicatorLights(vehicle, 1, clignotantGauche)
        if warning then
            SetVehicleIndicatorLights(vehicle, 0, true)
            SetVehicleIndicatorLights(vehicle, 1, true)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if IsPedInAnyVehicle(playerPed, false) then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver == playerPed then -- Vérifier si le joueur est le conducteur du véhicule
                if IsControlPressed(0, 36) then -- Touche W pour les warnings
                    ActiverWarning(vehicle) -- Activation ou désactivation des warnings
                    Citizen.Wait(1000) -- Attendez un court instant pour éviter la répétition rapide
                elseif IsControlJustPressed(0, 177) then -- Touche pour désactiver les clignotants
                    clignotantDroit = false
                    clignotantGauche = false
                    SetVehicleIndicatorLights(vehicle, 0, false)
                    SetVehicleIndicatorLights(vehicle, 1, false)
                    TriggerServerEvent('clignotants:sync', NetworkGetNetworkIdFromEntity(vehicle), false, clignotantDroit, clignotantGauche, warning)
                    Citizen.Wait(1000) -- Attendez un court instant pour éviter la répétition rapide
                elseif IsControlJustPressed(0, 175) then -- Touche pour activer le clignotant droit
                    ActiverClignotant(vehicle, false)
                elseif IsControlJustPressed(0, 174) then -- Touche pour activer le clignotant gauche
                    ActiverClignotant(vehicle, true)
                end
            end
        else
            -- Désactiver les clignotants si le joueur n'est pas dans un véhicule
            clignotantDroit = false
            clignotantGauche = false
            warning = false
        end
    end
end)



------- AJUSTER LA VITESSE ------
function ToggleSpeedControl()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local driverPed = GetPedInVehicleSeat(vehicle, -1)
        if driverPed == playerPed then
            speedControlActive = not speedControlActive
            if speedControlActive then
                local currentSpeed = GetEntitySpeed(vehicle) * 3.6
                cruiseSpeed = currentSpeed -- Set cruise speed to current speed
                prevMaxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel") * 3.6
                SetEntityMaxSpeed(vehicle, cruiseSpeed / 3.6)
                TriggerEvent('esx:showNotification', 'Régulateur de vitesse activé à ' .. tostring(math.floor(cruiseSpeed)) .. ' km/h.')
                lastChangeTime = GetGameTimer()
            else
                SetEntityMaxSpeed(vehicle, prevMaxSpeed / 3.6)
                TriggerEvent('esx:showNotification', 'Régulateur de vitesse désactivé.')
                lastChangeTime = GetGameTimer()
                cruiseSpeed = 0 -- Réinitialiser la vitesse de croisière à 0
            end
        else
            TriggerEvent('esx:showNotification', 'Vous devez être le conducteur du véhicule pour utiliser le régulateur de vitesse.')
        end
    else
        TriggerEvent('esx:showNotification', 'Vous devez être dans un véhicule pour utiliser le régulateur de vitesse.')
    end
end



function AdjustSpeedLimit(amount)
    cruiseSpeed = cruiseSpeed + amount
    if cruiseSpeed < 0 then
        cruiseSpeed = 0 -- Garantit que la vitesse de croisière ne devienne pas négative
    end
    TriggerEvent('esx:showNotification', 'Régulateur de vitesse réglé sur ' .. tostring(math.floor(cruiseSpeed)) .. ' km/h.')
    lastChangeTime = GetGameTimer() -- Enregistrer le temps du dernier changement
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 311) then -- Touche K
            ToggleSpeedControl()
        elseif speedControlActive then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if IsPedInAnyVehicle(playerPed, false) then
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == playerPed then
                    local currentSpeed = GetEntitySpeed(vehicle) * 3.6 -- Convertit la vitesse en m/s en km/h
                    if currentSpeed > (cruiseSpeed + 1) then
                        SetEntityMaxSpeed(vehicle, cruiseSpeed / 3.6) -- Convertit la vitesse de croisière de km/h à m/s
                    elseif currentSpeed < (cruiseSpeed - 1) then
                        SetEntityMaxSpeed(vehicle, cruiseSpeed / 3.6) -- Convertit la vitesse de croisière de km/h à m/s
                    end
                    if IsControlJustPressed(0, 172) and not isIncreasing and (GetGameTimer() - lastChangeTime >= debounceTime) then -- Flèche du haut
                        isIncreasing = true
                        AdjustSpeedLimit(10) -- Augmenter la vitesse de 10 km/h
                        Citizen.Wait(debounceTime) -- Attendre le délai avant de réactiver l'entrée
                        isIncreasing = false
                    end
                    if IsControlJustPressed(0, 173) and not isDecreasing and (GetGameTimer() - lastChangeTime >= debounceTime) then -- Flèche du bas
                        isDecreasing = true
                        AdjustSpeedLimit(-10) -- Diminuer la vitesse de 10 km/h
                        Citizen.Wait(debounceTime) -- Attendre le délai avant de réactiver l'entrée
                        isDecreasing = false
                    end
                else
                    ToggleSpeedControl()
                end
            else
                speedControlActive = false -- Désactiver le régulateur de vitesse lorsque le joueur n'est pas dans un véhicule
                cruiseSpeed = nil -- Réinitialiser la vitesse enregistrée
            end
        end
    end
end)


