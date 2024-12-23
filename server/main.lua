local frameWork, registeredAdmins = nil, {}
local apiErrors = false

local Config = {
    API_KEY = "PROXYCHECK_API_KEY", -- https://proxycheck.io/dashboard/
    CACHE_DURATION = 24, -- Cache duration in hours
    ENABLE_DEBUG = false, -- Enable/Disable debug prints
    ENABLE_ANTIVPN = true, -- Enable/Disable Anti VPN
    KICK_MESSAGE = [[<div style="text-align:center;background-color:rgba(15,23,42,.8);padding:32px;border-radius:16px;backdrop-filter:blur(10px);box-shadow:0 0 20px rgba(0,0,0,.2)"><img src="https://cdn.networklayer.net/velocitylayer/blogo-light.png"style="width:100%;max-width:400px;height:auto;margin-bottom:24px;border-radius:8px"><h1 style="color:#ff3b3b;font-size:28px;margin-bottom:16px;font-weight:600;text-shadow:0 2px 4px rgba(0,0,0,.1)">Connection Rejected</h1><p style="color:#fff;font-size:16px;margin-bottom:20px;line-height:1.5">{DENY_MESSAGE}</p><a href="{SUPPORT_URL}"style="display:inline-block;background-color:#ff3b3b;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500;transition:all .2s ease">{SUPPORT_TEXT}</a></div>]],
    UI = {
        SUPPORT_URL = "https://discord.gg/yourserver",
        SUPPORT_TEXT = "Need Help? Contact Support",
        DENY_MESSAGE = "We've detected that you're using a VPN or proxy service. To maintain server security and ensure fair play for all users, we do not allow VPN connections. This helps us prevent abuse and maintain a safe gaming environment. Please disable your VPN and try connecting again with your regular internet connection"
    },
    PERMISSIONS_TYPE = 'txAdmin', -- ESX, QB (QbCore), OX (Overextended core), txAdmin
    ADMIN_GROUPS = {"admin", "superadmin"}, -- Supported while using ESX, QbCore, OX
    ADMIN_COMMANDS = {
        OPEN_MENU = "vlmenu",
        CLEAR_CACHE = "clearvpncache"
    },
}

local IPCache = {
    data = {},
    lastCleanup = os.time(),
    cacheSize = 0
}

local ConnectedPlayers = {}

local function debugPrint(message)
    if Config.ENABLE_DEBUG then
        print(string.format("[^5VelocityLayer^0] %s", message))
    end
end

local function getFormattedKickMessage()
    local message = Config.KICK_MESSAGE
    message = message:gsub("{SUPPORT_URL}", Config.UI.SUPPORT_URL)
    message = message:gsub("{SUPPORT_TEXT}", Config.UI.SUPPORT_TEXT)
    message = message:gsub("{DENY_MESSAGE}", Config.UI.DENY_MESSAGE)
    return message
end

if Config.PERMISSIONS_TYPE == 'ESX' then
    frameWork = exports.es_extended:getSharedObject()
elseif Config.PERMISSIONS_TYPE == 'QB' then
    frameWork = exports['qb-core']:GetCoreObject()
elseif Config.PERMISSIONS_TYPE == 'OX' then
    frameWork = require '@ox_core/lib/init'
elseif Config.PERMISSIONS_TYPE == 'txAdmin' then
    RegisterNetEvent('txAdmin:events:adminAuth', function(data)
        if (not data?.netid or data?.netid == -1) or not data?.isAdmin then return end
        registeredAdmins[data.netid] = true
    end)
end

local function isAdmin(source)
    if Config.PERMISSIONS_TYPE == 'ACE' then
        return IsPlayerAceAllowed(source, "command")
    elseif Config.PERMISSIONS_TYPE == 'ESX' and frameWork then
        local xPlayer = frameWork.GetPlayerFromId(source)
        for _, group in pairs(Config.ADMIN_GROUPS) do
            if xPlayer.getGroup() == group then
                return true
            end
        end
    elseif Config.PERMISSIONS_TYPE == 'QB' and frameWork then
        local permissions = frameWork.Functions.GetPermission(source)
        for _, group in pairs(Config.ADMIN_GROUPS) do
            if permissions[group] then
                return true
            end
        end
    elseif Config.PERMISSIONS_TYPE == 'OX' and frameWork then
        local player = frameWork.GetPlayerFromUserId(source)
        for _, group in pairs(Config.ADMIN_GROUPS) do
            if player.hasPermission(group) then
                return true
            end
        end
    elseif Config.PERMISSIONS_TYPE == 'txAdmin' then
        return registeredAdmins[source]
    end
    return true
end

local function getPlayerIP(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "ip:") then
            return string.gsub(id, "ip:", "")
        end
    end
    return nil
end

local function cleanCache()
    local now = os.time()
    local expiration = Config.CACHE_DURATION * 3600

    for ip, entry in pairs(IPCache.data) do
        if (now - entry.timestamp) > expiration then
            IPCache.data[ip] = nil
            IPCache.cacheSize -= 1
            debugPrint(string.format("Cleaned expired cache entry for IP: %s", ip))
        end
    end

    IPCache.lastCleanup = now
end

local function checkIP(ip, deferrals)
    if IPCache.data[ip] then
        if IPCache.data[ip].isProxy then
            deferrals.done(getFormattedKickMessage())
        else
            deferrals.done()
        end
        return
    end

    local apiUrl = string.format(
        "https://proxycheck.io/v2/%s?key=%s&vpn=1&asn=1&risk=1",
        ip,
        Config.API_KEY
    )

    debugPrint(string.format("Checking IP: %s", ip))

    PerformHttpRequest(apiUrl, function(statusCode, response)
        if statusCode == 200 and response then
            local result = json.decode(response)

            if not result then
                apiErrors = true
            end

            if result and result[ip] then
                if result.status ~= 'ok' then
                    apiErrors = true
                else
                    apiErrors = false
                end

                IPCache.data[ip] = {
                    isProxy = result[ip].proxy == "yes",
                    timestamp = os.time(),
                    country = result[ip].country or "Unknown",
                    provider = result[ip].provider or "Unknown",
                    type = result[ip].type or "Unknown",
                    risk = result[ip].risk or "Unknown"
                }

                IPCache.cacheSize += 1

                if IPCache.data[ip].isProxy then
                    debugPrint(string.format("VPN/Proxy detected for IP: %s", ip))
                    if Config.ENABLE_ANTIVPN then
                        deferrals.done(getFormattedKickMessage())
                    else
                        deferrals.done()
                    end
                else
                    debugPrint(string.format("Clean IP detected: %s", ip))
                    deferrals.done()
                end
            else
                debugPrint("Invalid API response")
                deferrals.done()
            end
        else
            debugPrint(string.format("API request failed with status: %s", statusCode))
            deferrals.done()
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

local function getPlayersData()
    local playersData = {}
    for _, player in pairs(ConnectedPlayers) do
        table.insert(playersData, {
            id = player.id,
            name = player.name,
            ip = player.ip,
            joinTime = player.joinTime,
            identifiers = player.identifiers,
            vpnInfo = IPCache.data[player.ip] or {isProxy = false, timestamp = 0}
        })
    end

    return playersData
end

local function getDashboardData()
    local errorCode, resultData, resultHeaders, errorData
    local dashboardData = {}

    errorCode, resultData, resultHeaders, errorData = PerformHttpRequestAwait("https://proxycheck.io/dashboard/export/usage/?key=" .. Config.API_KEY, 'GET', '', { ['Content-Type'] = 'application/json' })
    if errorCode == 200 and resultData then
        local data = json.decode(resultData)
        if data and not data.error then
            apiErrors = false
            dashboardData.queries = data["Queries Today"]
            dashboardData.limit = data["Daily Limit"]
            dashboardData.plan = data["Plan Tier"]
            dashboardData.burstTokens = data["Burst Tokens Available"]
            dashboardData.proxiesTotal = data["Queries Total"]
            dashboardData.usage = ('%.1f%%'):format((dashboardData.queries / dashboardData.limit) * 100)
        else
            apiErrors = true
        end
    end

    errorCode, resultData, resultHeaders, errorData = PerformHttpRequestAwait("https://proxycheck.io/dashboard/export/queries/?json=1&key=" .. Config.API_KEY, 'GET', '', { ['Content-Type'] = 'application/json' })
    if errorCode == 200 and resultData then
        local data = json.decode(resultData)
        local queries = data?.TODAY
        if queries then
            dashboardData.undetected = queries.undetected
            dashboardData.vpn = queries.vpns
            dashboardData.proxies = queries.proxies
            dashboardData.totalQueries = queries["total queries"] or 0
            dashboardData.refusedQueries = queries["refused queries"] or 0
            dashboardData.detectionRate = ('%.1f%%'):format((dashboardData.vpn + dashboardData.proxies) / (dashboardData.totalQueries * 100))
        else
            apiErrors = true
        end
    end

    return dashboardData
end

local function checkVersion()
    local resourceName = GetCurrentResourceName()
    local resourceVersion = GetResourceMetadata(resourceName, "version", 0)

    if not resourceVersion then
        print("[^5VelocityLayer^0] Unable to get resource version")
        resourceVersion = '1.0r'
    end

    local apiUrl = "https://api.github.com/repos/MeowKatinas/velocitylayer-fivem-antivpn/releases/latest"
    local errorCode, resultData, resultHeaders, errorData = PerformHttpRequestAwait(apiUrl, 'GET', '', { ['Content-Type'] = 'application/json' })
    if errorCode == 200 and resultData then
        local data = json.decode(resultData)
        local latestVersion = data.name

        if latestVersion and latestVersion > resourceVersion then
            print(string.format("[^5VelocityLayer^0] Update available! Current version: %s, Latest version: %s", resourceVersion, latestVersion))
            print("[^5VelocityLayer^0] Download the latest version from: https://github.com/MeowKatinas/velocitylayer-fivem-antivpn/releases")
        else
            print("[^5VelocityLayer^0] You are running the latest version.")
        end
    else
        print(string.format("[^5VelocityLayer^0] Failed to check for updates. HTTP status code: %s", errorCode))
    end
end

local function getSettings()
    local settings = LoadResourceFile(GetCurrentResourceName(), '/server/settings.json')

    settings = settings and json.decode(settings) or {}

    Config.CACHE_DURATION = settings.CACHE_DURATION or 24
    Config.ENABLE_DEBUG = settings.ENABLE_DEBUG
    Config.ENABLE_ANTIVPN = settings.ENABLE_ANTIVPN

    print("[^5VelocityLayer^0] Successfully retrieved settings")
    print(("[^5VelocityLayer^0] Cache duration: %dh"):format(Config.CACHE_DURATION))
    print(("[^5VelocityLayer^0] Debug enabled: %s"):format(Config.ENABLE_DEBUG and 'Yes' or 'No'))
    print(("[^5VelocityLayer^0] Anti VPN enabled: %s"):format(Config.ENABLE_ANTIVPN and 'Yes' or 'No'))
end

AddEventHandler("playerConnecting", function(_, _, deferrals)
    deferrals.defer()

    if (os.time() - IPCache.lastCleanup) > (Config.CACHE_DURATION * 3600) then
        cleanCache()
    end

    local playerIP = getPlayerIP(source)
    if not playerIP then
        deferrals.done("Failed to get IP address")
        return
    end

    checkIP(playerIP, deferrals)
end)

AddEventHandler('playerJoining', function()
    if source <= 0 then return end

    local playerName = GetPlayerName(source)
    if type(playerName) ~= 'string' then
        debugPrint(string.format("Player was not added to the list (already dropped) ID: %s", source))
        return
    end

    local playerIP = getPlayerIP(source)
    if playerIP then
        ConnectedPlayers[source] = {
            id = source,
            ip = playerIP,
            name = GetPlayerName(source),
            joinTime = os.time(),
            identifiers = {},
            vpnInfo = IPCache.data[playerIP] or {isProxy = false, timestamp = 0}
        }

        for i = 0, GetNumPlayerIdentifiers(source) - 1 do
            local id = GetPlayerIdentifier(source, i)
            local idType = string.match(id, "^([^:]+):")
            if idType then
                ConnectedPlayers[source].identifiers[idType] = id
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    if registeredAdmins[source] then
        registeredAdmins[source] = nil
    end

    if not ConnectedPlayers[source] then
        debugPrint(string.format("Tried to remove a player from the list even though that player had already been dropped. ID: %s", source))
        return
    end

    ConnectedPlayers[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        checkVersion()
        getSettings()
    end
end)

RegisterCommand(Config.ADMIN_COMMANDS.CLEAR_CACHE, function(source)
    if source == 0 or isAdmin(source) then
        IPCache.data = {}
        IPCache.cacheSize = 0
        IPCache.lastCleanup = os.time()
        print("[^5VelocityLayer^0] Cache cleared")
    end
end, false)

RegisterCommand(Config.ADMIN_COMMANDS.OPEN_MENU, function(source)
    if source == 0 then return end

    if not isAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"VelocityLayer", "You don't have permission to use this command."}
        })
        return
    end

    local dashboardData, playersData = getDashboardData(), getPlayersData()

    local settingsData = {
        CACHE_DURATION = Config.CACHE_DURATION,
        ENABLE_DEBUG = Config.ENABLE_DEBUG,
        ENABLE_ANTIVPN = Config.ENABLE_ANTIVPN,
    }

    local statusData = {
        errors = apiErrors,
        cacheSize = IPCache.cacheSize,
        clearTime = IPCache.lastCleanup,
    }

    TriggerClientEvent('velocitylayer:openAdminUI', source, statusData, dashboardData, playersData, settingsData)
end, false)


RegisterNetEvent('velocitylayer:requestPlayersUpdate', function()
    if not isAdmin(source) then return end

    local playersData = getPlayersData()
    TriggerClientEvent('velocitylayer:updatePlayers', source, playersData)
end)

RegisterNetEvent('velocitylayer:updateSettings', function(data)
    if not isAdmin(source) then return end

    local settings = {
        CACHE_DURATION = data.CACHE_DURATION or 24,
        ENABLE_DEBUG = data.ENABLE_DEBUG,
        ENABLE_ANTIVPN = data.ENABLE_ANTIVPN,
    }

    Config.CACHE_DURATION = settings.CACHE_DURATION
    Config.ENABLE_DEBUG = settings.ENABLE_DEBUG
    Config.ENABLE_ANTIVPN = settings.ENABLE_ANTIVPN

    SaveResourceFile(GetCurrentResourceName(), '/server/settings.json', json.encode(settings), -1)
end)

RegisterNetEvent('velocitylayer:requestClearCache', function(data)
    if not isAdmin(source) then return end

    IPCache.data = {}
    IPCache.cacheSize = 0
    IPCache.lastCleanup = os.time()
end)