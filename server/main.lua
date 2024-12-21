local Config = {
    API_KEY = "PROXYCHECK_API_KEY",
    CACHE_DURATION = 24,
    ENABLE_DEBUG = false,
    KICK_MESSAGE = [[<div style="text-align:center;background-color:rgba(15,23,42,.8);padding:32px;border-radius:16px;backdrop-filter:blur(10px);box-shadow:0 0 20px rgba(0,0,0,.2)"><img src="https://cdn.networklayer.net/velocitylayer/blogo-light.png"style="width:100%;max-width:400px;height:auto;margin-bottom:24px;border-radius:8px"><h1 style="color:#ff3b3b;font-size:28px;margin-bottom:16px;font-weight:600;text-shadow:0 2px 4px rgba(0,0,0,.1)">Connection Rejected</h1><p style="color:#fff;font-size:16px;margin-bottom:20px;line-height:1.5">{DENY_MESSAGE}</p><a href="{SUPPORT_URL}"style="display:inline-block;background-color:#ff3b3b;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500;transition:all .2s ease">{SUPPORT_TEXT}</a></div>]],
    UI = {
        SUPPORT_URL = "https://discord.gg/yourserver",
        SUPPORT_TEXT = "Need Help? Contact Support",
        DENY_MESSAGE = "We've detected that you're using a VPN or proxy service. To maintain server security and ensure fair play for all users, we do not allow VPN connections. This helps us prevent abuse and maintain a safe gaming environment. Please disable your VPN and try connecting again with your regular internet connection"
    },
    CURRENT_VERSION ="1.0r"
}

local function getFormattedKickMessage()
    local message = Config.KICK_MESSAGE
    message = message:gsub("{SUPPORT_URL}", Config.UI.SUPPORT_URL)
    message = message:gsub("{SUPPORT_TEXT}", Config.UI.SUPPORT_TEXT)
    message = message:gsub("{DENY_MESSAGE}", Config.UI.DENY_MESSAGE)
    return message
end

local IPCache = {
    data = {},
    lastCleanup = os.time()
}

local function debugPrint(message)
    if Config.ENABLE_DEBUG then
        print(string.format("[VelocityLayer] %s", message))
    end
end

local function cleanCache()
    local now = os.time()
    local expiration = Config.CACHE_DURATION * 3600 
    
    for ip, entry in pairs(IPCache.data) do
        if (now - entry.timestamp) > expiration then
            IPCache.data[ip] = nil
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
        "https://proxycheck.io/v2/%s?key=%s&vpn=1&asn=1",
        ip,
        Config.API_KEY
    )
    
    debugPrint(string.format("Checking IP: %s", ip))
    
    PerformHttpRequest(apiUrl, function(statusCode, response)
        if statusCode == 200 and response then
            local result = json.decode(response)
            
            if result and result[ip] then
                IPCache.data[ip] = {
                    isProxy = result[ip].proxy == "yes",
                    timestamp = os.time()
                }
                
                if IPCache.data[ip].isProxy then
                    debugPrint(string.format("VPN/Proxy detected for IP: %s", ip))
                    deferrals.done(getFormattedKickMessage())
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

local function getPlayerIP(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "ip:") then
            return string.gsub(id, "ip:", "")
        end
    end
    return nil
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

RegisterCommand('clearvpncache', function(source)
    if source == 0 then -- Console only
        IPCache.data = {}
        IPCache.lastCleanup = os.time()
        print("[VelocityLayer] Cache cleared")
    end
end)

local function checkVersion()
    local apiUrl = string.format("https://api.github.com/repos/MeowKatinas/velocitylayer-fivem-antivpn/releases/latest")
    PerformHttpRequest(apiUrl, function(statusCode, response)
        if statusCode == 200 and response then
            local data = json.decode(response)
            local latestVersion = data.tag_name

            if latestVersion and latestVersion > Config.CURRENT_VERSION then
                print(string.format("[VelocityLayer] Update available! Current version: %s, Latest version: %s", Config.CURRENT_VERSION, latestVersion))
                print(string.format("[VelocityLayer] Download the latest version from: https://github.com/MeowKatinas/velocitylayer-fivem-antivpn/releases"))
            else
                print("[VelocityLayer] You are running the latest version.")
            end
        else
            print(string.format("[VelocityLayer] Failed to check for updates. HTTP status code: %s", statusCode))
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        checkVersion()
    end
end)
