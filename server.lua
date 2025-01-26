local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb_weedgather:kenevirVer')
AddEventHandler('qb_weedgather:kenevirVer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        Player.Functions.AddItem(Config.ItemAdi, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ItemAdi], "add")
    end
end)
