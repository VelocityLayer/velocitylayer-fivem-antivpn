local display = false

RegisterNetEvent('velocitylayer:openAdminUI', function(statusData, dashboardData, playersData, settingsData)
    if display then return end
    display = true

    SendNUIMessage({
        type = "menu",
        show = true,
        status = statusData,
    })

    SendNUIMessage({
        type = "dashboard",
        data = dashboardData,
    })

    SendNUIMessage({
        type = "players",
        players = playersData,
    })

    SendNUIMessage({
        type = "settings",
        settings = settingsData,
    })

    SetNuiFocus(true, true)
end)

RegisterNetEvent('velocitylayer:updatePlayers', function(playersData)
    if not display then return end

    SendNUIMessage({
        type = "players",
        players = playersData,
    })
end)

RegisterNUICallback('closeUI', function()
    display = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('refreshData', function()
    TriggerServerEvent('velocitylayer:requestPlayersUpdate')
end)

RegisterNUICallback('saveSettings', function(data)
    TriggerServerEvent('velocitylayer:updateSettings', data)
end)

RegisterNUICallback('clearCache', function(data)
    TriggerServerEvent('velocitylayer:requestClearCache')
end)