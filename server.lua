RegisterServerEvent('trabajo_piloto:pagar', function()
    local player = ESX.GetPlayerFromId(source)
    player.addMoney(500)
end)