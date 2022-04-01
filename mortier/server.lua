-------------------
-- Synced events --
-------------------

-- Send an event to the players

RegisterServerEvent("fwmortar:server:shoot")
AddEventHandler("fwmortar:server:shoot", function()
    TriggerClientEvent("fwmortar:client:fx", -1, source)
end)
