ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('clignotants:sync')
AddEventHandler('clignotants:sync', function(netId, gauche, clignotantDroit, clignotantGauche, warning)
    TriggerClientEvent('clignotants:update', -1, netId, gauche, clignotantDroit, clignotantGauche, warning)
end)
