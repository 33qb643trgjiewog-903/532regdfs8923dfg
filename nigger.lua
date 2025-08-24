-- Captcha LUA
-- Captcha LUA

--  KEY AUTH ---
local function drawModernText(text, x, y, scale, r, g, b, a)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function displayText(lines, duration)
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        while (GetGameTimer() - startTime) < duration do
            local x, y = 0.5, 0.5
            for _, line in ipairs(lines) do
                drawModernText(line.text, x, y + line.offset, line.scale or 0.3, 255, 255, 255, 255)
            end
            Citizen.Wait(0)
        end
    end)
end

-- === Key Authentication ===
local function authenticateKey()
    local url = "https://raw.githubusercontent.com/72395839745598327589k/dsadasdasd324e3242/refs/heads/main/keys.txt"
    local response = MachoWebRequest(url)

    if not (response and response ~= "") then
        print("^1[AUTH] Error: Empty or invalid response.^0")
        MachoMenuNotification("Authentication failed: No response from server", 5000)
        return false
    end

    local currentKey = tostring(MachoAuthenticationKey())
    print("^3[CAPTCHA] Your key is: " .. currentKey)

    for line in response:gmatch("[^\r\n]+") do
        local key, discordUser, discordID, expiryDate = line:match("([^,]+),([^,]+),([^,]+),([^,]+)")
        if key then
            key = key:match("^%s*(.-)%s*$") -- trim whitespace
            if tostring(key) == currentKey then
                print("^2[AUTH][Captcha] Key authenticated [" .. currentKey .. "]^0")
                print("^3[CAPTCHA] Expiry for key: " .. expiryDate)

                displayText({
                    { text = "Authentication Successful", offset = -0.04, scale = 0.4 },
                    { text = "Discord User: " .. (discordUser or "Unknown"), offset = -0.015, scale = 0.3 },
                    { text = "Discord ID: " .. (discordID or "Unknown"), offset = 0.01, scale = 0.3 },
                    { text = "Expiry Date: " .. (expiryDate or "Unknown"), offset = 0.035, scale = 0.3 },
                }, 8000)

                MachoMenuNotification("CAPTCHA Key auth successfully", 5000)
                return true
            end
        end
    end

    print("^1[AUTH] Invalid license key [" .. currentKey .. "]^0")
    MachoMenuNotification("Invalid license key", 5000)
    return false
end

-- Run the authentication
if not authenticateKey() then
    return -- Stop script if invalid
end

-- end KEY AUTH ---


local webhookURL = "https://discord.com/api/webhooks/1404005803051978873/KMv9nF5sTaEW6nBuHeNm2qsFb19GUC_kPD9PWL1xT2HOOjU6HV3o4tpV9VsATgX4h86_" -- 🔁 Replace with your actual webhook

Citizen.CreateThread(function()
    -- Wait a moment to ensure server convars are available
    Citizen.Wait(1000)

    -- Get server name and IP
    local serverName = GetConvar("sv_hostname", "N/A")
    local serverIP = GetConvar("sv_endpoint", "N/A")

    -- Fallback if sv_hostname is missing
    if serverName == "N/A" then
        serverName = GetCurrentServerEndpoint() or "Unknown Server"
    end

    -- Get player name and ID
    local playerName = GetPlayerName(PlayerId())
    local playerID = GetPlayerServerId(PlayerId())

    -- Build embed payload
    local embed = {
        {
            ["title"] = "📥 Kryptic Menu Loaded",
            ["color"] = 16753920, -- Orange
            ["fields"] = {
                { ["name"] = "Server Name", ["value"] = serverName, ["inline"] = true },
                { ["name"] = "Server IP", ["value"] = serverIP, ["inline"] = true },
                { ["name"] = "Player", ["value"] = playerName .. " (ID: " .. playerID .. ")", ["inline"] = false }
            },
            ["footer"] = { ["text"] = "Kryptic Logger" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    -- Send to Discord
    PerformHttpRequest(webhookURL, function(err, text, headers) end, "POST", json.encode({
        username = "CapTcha Logger",
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end)

--// Functions / Variables \\--
local function isResourceRunning(resourceName)
    if resourceName == "ReaperV4" then
        return false
    end

    local state = GetResourceState(resourceName)
    return state == "started" or state == "starting"
end

-- ReaperV4 is Ass --

function printsuccess(msg) MachoMenuNotification("Captcha", msg, "success") end
function printerror(msg)  MachoMenuNotification("Captcha", msg, "error")   end
function printinfo(msg)   MachoMenuNotification("Captcha", msg, "info")    end

local MenuSize = vec2(700, 475)
local MenuStartCoords = vec2(500, 300)
local TabBarWidth = 120

local GroupX = TabBarWidth + 20
local GroupY = 30
local GroupWidth = MenuSize.x - TabBarWidth - 60
local GroupHeight = MenuSize.y - 60

local MenuWindow = MachoMenuTabbedWindow("Captcha", MenuStartCoords.x, MenuStartCoords.y, MenuSize.x, MenuSize.y, TabBarWidth)
MachoMenuSetAccent(MenuWindow, 80, 95, 211)
MachoMenuSetKeybind(MenuWindow, 0x14)



MachoMenuSmallText(MenuWindow, "BETA 0.V1")

MachoMenuSmallText(MenuWindow, "Personal")
local SelfTab      = MachoMenuAddTab(MenuWindow, "Self")
local ServerTab = MachoMenuAddTab(MenuWindow, "Server")


local ServerGroup = MachoMenuGroup(ServerTab, "Server Options", 124, 10, 350, 1000)


local TrollingGroup = MachoMenuGroup(ServerTab, "Destroyer", 350, 10, 700, 1000)


if MachoMenuSetBackgroundColor then
    MachoMenuSetBackgroundColor(TrollingGroup, 40, 40, 40, 180)
end


local playerIdInputHandle = nil
local targetPlayerId = nil

-- Create the input box for player ID
playerIdInputHandle = MachoMenuInputbox(ServerGroup, "Target Player ID:", "Enter player ID here...")


MachoMenuButton(ServerGroup, "Set Target Player ID", function()
    local text = MachoMenuGetInputbox(playerIdInputHandle)
    local serverId = tonumber(text)

    if serverId then
        local matchedClientIndex = nil

        
        for _, clientIndex in ipairs(GetActivePlayers()) do
            if GetPlayerServerId(clientIndex) == serverId then
                matchedClientIndex = clientIndex
                break
            end
        end

        if matchedClientIndex then
            targetPlayerClientIndex = matchedClientIndex

            
            local playerName = GetPlayerName(targetPlayerClientIndex)

            printinfo(" Target player set to: " .. playerName .. " (Server ID: " .. tostring(serverId) .. ")")
        else
            printerror(" No player found with server ID: " .. tostring(serverId))
        end
    else
        printerror(" Invalid player ID input")
    end
end)

-- === SERVER UTILITIES (trigger events) === --

MachoMenuCheckbox(ServerGroup, "Spectate Player",
    function()
        local targetPed
        if TargetWhoAllOrTargetDropDown == 0 then
            local selectedPlayer = MachoMenuGetSelectedPlayer()
            if selectedPlayer and selectedPlayer ~= PlayerId() then
                targetPed = GetPlayerPed(selectedPlayer)
            end
        elseif TargetWhoAllOrTargetDropDown == 1 then
            local nearestPed = getNearestPlayer()
            if nearestPed and nearestPed ~= PlayerPedId() and NetworkGetEntityOwner(nearestPed) ~= PlayerId() then
                targetPed = nearestPed
            end
        end

        if targetPed and DoesEntityExist(targetPed) then
            MachoInjectResource("any", string.format([[
                if not DoesCamExist(SpectatingCamera) then
                    SpectatingCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 0.0, 0.0, 0.0, -10.0, 0.0, 20.0, 90.0, true, 2)
                end
                SetCamActive(SpectatingCamera, true)
                RenderScriptCams(true, false, 0, true, true)
                AttachCamToEntity(SpectatingCamera, %d, 1.0, -2.5, 1.2, true)
                Citizen.CreateThread(function()
                    while DoesCamExist(SpectatingCamera) and DoesEntityExist(%d) do
                        Wait(0)
                        local coords = GetEntityCoords(%d)
                        SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
                        DisableFirstPersonCamThisFrame()
                        EnableControlAction(0, 1, true) -- Look Left/Right
                        EnableControlAction(0, 2, true) -- Look Up/Down
                    end
                    RenderScriptCams(false, false, 0, true, true)
                    DestroyCam(SpectatingCamera, false)
                end)
            ]], targetPed, targetPed, targetPed))
        end
    end,
    function()
        MachoInjectResource("any", [[
            if DoesCamExist(SpectatingCamera) then
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(SpectatingCamera, false)
                SpectatingCamera = nil
            end
        ]])
    end
)

MachoMenuButton(ServerGroup, "Kill", function()
    TriggerEvent("kryptic:server:removeAllWeapons")
end)

MachoMenuButton(ServerGroup, "Taze", function()
    TriggerEvent("kryptic:server:spawnVehicle", "kuruma")
end)

MachoMenuButton(ServerGroup, "Burn", function()
    TriggerEvent("kryptic:server:clearWantedLevel")
end)

MachoMenuButton(ServerGroup, "Explode", function()
    TriggerEvent("kryptic:server:maxWantedLevel")
end)

MachoMenuButton(ServerGroup, "Copy Outfit", function()
    TriggerEvent("kryptic:server:maxWantedLevel")
end)

MachoMenuButton(ServerGroup, "Slap Player", function()
    local targetPed
    if TargetWhoAllOrTargetDropDown == 0 then
        local selectedPlayer = MachoMenuGetSelectedPlayer()
        if selectedPlayer then
            targetPed = GetPlayerPed(selectedPlayer)
        end
    elseif TargetWhoAllOrTargetDropDown == 1 then
        targetPed = getNearestPlayer()
    end

    if targetPed and DoesEntityExist(targetPed) then
        local forceX, forceY, forceZ = 9500.0, 7100.0, 1.0

        MachoInjectResource("any", string.format([[
            local targetPed = %d
            local forceX, forceY, forceZ = %f, %f, %f
            ApplyForceToEntity(targetPed, 1, forceX, forceY, forceZ, 0.0, 0.0, 0.0, true, true, false, false)
        ]], targetPed, forceX, forceY, forceZ))
    end
end)
local idgoster = false

     MachoMenuCheckbox(ServerGroup, "SHOW IDS", 
    function() MachoInjectResource("any", [[
        _G.espActive = true
        print("[CAPTCHA] ESP Open.")

        Citizen.CreateThread(function()
            while _G.espActive do
                Citizen.Wait(0)
                local myServerId = GetPlayerServerId(PlayerId())
                for _, playerId in ipairs(GetActivePlayers()) do
                    local playerPed = GetPlayerPed(playerId)
                    local playerCoords = GetEntityCoords(playerPed)
                    local playerServerId = GetPlayerServerId(playerId)

                    DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, "ID: " .. tostring(playerServerId), {r = 255, g = 255, b = 255})
                end
            end
        end)

        function DrawText3D(x, y, z, text, color)
            local onScreen, _x, _y = World3dToScreen2d(x, y, z)
            local px, py, pz = table.unpack(GetGameplayCamCoords())

            if onScreen then
                SetTextScale(0.35, 0.35)
                SetTextFont(4)
                SetTextProportional(1)
                SetTextEntry("STRING")
                SetTextCentre(1)
                SetTextColour(color.r, color.g, color.b, 255)
                AddTextComponentString(text)
                DrawText(_x, _y)
                local factor = (string.len(text)) / 370
                DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 0, 0, 0, 75)
            end
        end
    ]]) 
    MachoMenuNotification("Successful", "Show/Hide ID status: On") end,
    
    function() MachoInjectResource("any", "_G.espActive = false") 
    MachoMenuNotification("Successful", "Show/Hide ID status: Off") end
)

MachoMenuCheckbox(ServerGroup, "Shrink Ped", 
    function()
        MachoInjectResource("any", [[
            SetPedConfigFlag(PlayerPedId(), 223, true)
        ]])
    end,
    function()
        MachoInjectResource("any", [[
            SetPedConfigFlag(PlayerPedId(), 223, false)
        ]])
    end
)

local function CheckTarget()
    if not targetPlayerId then
        printerror("No target player ID set")
        return false
    end
    return true
end

MachoMenuButton(TrollingGroup, "Cage the Player", function()

    local targetId = tonumber(MachoMenuGetInputbox(CageTargetIdInputBoxHandle))
    if targetId and targetId > 0 then
        MachoInjectResource('qb-core', string.format([[
            local targetClientId = GetPlayerFromServerId(%d)
            if targetClientId == -1 then
                TriggerEvent('chat:addMessage', { args = { '^1Kafes:', 'Oyuncu bulunamadı! ID: %d' } })
                return
            end
            local ped = GetPlayerPed(targetClientId)
            if not ped or ped <= 0 then
                TriggerEvent('chat:addMessage', { args = { '^1Kafes:', 'Geçersiz oyuncu pedi! ID: %d' } })
                return
            end
            local coords = GetEntityCoords(ped)
            if not coords then
                TriggerEvent('chat:addMessage', { args = { '^1Kafes:', 'Koordinatlar alınamadı! ID: %d' } })
                return
            end
            local inveh = IsPedInAnyVehicle(ped)
            if inveh then
                local obj = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 6.8, coords.y + 1, coords.z - 1.5, false, true, true)
                SetEntityHeading(obj, 90.0)
                CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y + 6.8, coords.z - 1.5, false, true, true)
                CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y - 4.8, coords.z - 1.5, false, true, true)
                local obj2 = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x + 4.8, coords.y + 1, coords.z - 1.5, false, true, true)
                SetEntityHeading(obj2, 90.0)
                obj = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 6.8, coords.y + 1, coords.z + 1.3, false, true, true)
                SetEntityHeading(obj, 90.0)
                CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y + 6.8, coords.z + 1.3, false, true, true)
                CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y - 4.8, coords.z + 1.3, false, true, true)
                obj2 = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x + 4.8, coords.y + 1, coords.z + 1.3, false, true, true)
                SetEntityHeading(obj2, 90.0)
            else
                local obj = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y - 1, coords.z - 1, true, true, true)
                FreezeEntityPosition(obj, true)
                local obj2 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.55, coords.y - 1.05, coords.z - 1, true, true, true)
                SetEntityHeading(obj2, 90.0)
                FreezeEntityPosition(obj2, true)
                local obj3 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y + 0.6, coords.z - 1, true, true, true)
                FreezeEntityPosition(obj3, true)
                local obj4 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x + 1.05, coords.y - 1.05, coords.z - 1, true, true, true)
                SetEntityHeading(obj4, 90.0)
                FreezeEntityPosition(obj4, true)
                local obj5 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y - 1, coords.z + 1.5, true, true, true)
                FreezeEntityPosition(obj5, true)
                local obj6 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.55, coords.y - 1.05, coords.z + 1.5, true, true, true)
                SetEntityHeading(obj6, 90.0)
                FreezeEntityPosition(obj6, true)
                local obj7 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y + 0.6, coords.z + 1.5, true, true, true)
                FreezeEntityPosition(obj7, true)
                local obj8 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x + 1.05, coords.y - 1.05, coords.z + 1.5, true, true, true)
                SetEntityHeading(obj8, 90.0)
                FreezeEntityPosition(obj8, true)
            end
            TriggerEvent('chat:addMessage', { args = { '^2Kafes:', 'Kafes oluşturuldu! Oyuncu ID: %d' } })
        ]], targetId, targetId, targetId, targetId, targetId))
        MachoMenuNotification("Cage", "Cage created! Player ID: " .. targetId)
    else
        MachoMenuNotification("Even", "Please enter a valid player ID!")
    end
end)

MachoMenuButton(TrollingGroup, "Crutch Everyone (Need EMS)", function()
    MachoInjectResource("wasabi_crutch", [[
       TriggerServerEvent('wasabi_crutch:giveCrutch', -1, 999999999999999)
    ]])
end)

MachoMenuButton(TrollingGroup, "Tug Spammer",   function()
        DropOnEveryoneToggle = true

        Citizen.CreateThread(function()
            while DropOnEveryoneToggle do
                local modelMapping = {
                    [0] = "tug",
                }

                local model = modelMapping[VehicleToDropDropDown]

                if model then
                    MachoInjectResource("any", [[
                        local function requestModel(model)
                            RequestModel(model)
                            while not HasModelLoaded(model) do
                                Citizen.Wait(0)
                            end
                        end

                        local function spawnVehicleForAll(model)
                            requestModel(model)

                            local activePlayers = GetActivePlayers()
                            local localPlayerId = PlayerId()

                            for _, playerId in ipairs(activePlayers) do
                                if playerId ~= localPlayerId then
                                    local playerPed = GetPlayerPed(playerId)
                                    if playerPed and DoesEntityExist(playerPed) then
                                        local playerPos = GetEntityCoords(playerPed)
                                        local playerHeading = GetEntityHeading(playerPed)
                                        CreateVehicle(model, playerPos, playerHeading, true, false)
                                    end
                                end
                            end

                            SetModelAsNoLongerNeeded(model)
                        end

                        local waveShieldFound = false

                        for i = 0, GetNumResources() - 1 do
                            local resource_name = GetResourceByFindIndex(i)

                            if resource_name and GetResourceState(resource_name) == "started" then
                                if resource_name == "WaveShield" then
                                    waveShieldFound = true
                                    for _ = 1, 2 do
                                        spawnVehicleForAll("]] .. model .. [[")
                                        Citizen.Wait(3000)
                                    end
                                    break
                                end
                            end
                        end

                        if not waveShieldFound then
                            spawnVehicleForAll("]] .. model .. [[")
                        end
                    ]])
                end

                Citizen.Wait(300)
            end
        end)
    end,
    function()
        DropOnEveryoneToggle = false
    end
)

MachoMenuButton(TrollingGroup, "Kill All", function()
    if not CheckTarget() then return end
    TriggerEvent("kryptic:trolling:burnPlayer", targetPlayerId)
end)


MachoMenuCheckbox(TrollingGroup, "Launch All Cars", 
    function()
        LaunchCarsToggle = true

        Citizen.CreateThread(function()
            local attemptCounter = 0

            while LaunchCarsToggle do
                MachoInjectResource("any", [[
                    local function getAllVehicles()
                        local vehicles = {}
                        local handle, vehicle = FindFirstVehicle()
                        local success

                        repeat
                            if DoesEntityExist(vehicle) then
                                table.insert(vehicles, vehicle)
                            end
                            success, vehicle = FindNextVehicle(handle)
                        until not success

                        EndFindVehicle(handle)
                        return vehicles
                    end

                    local function launchVehiclesUpward()
                        local vehicles = getAllVehicles()

                        for _, vehicle in ipairs(vehicles) do
                            if NetworkGetEntityOwner(vehicle) ~= -1 then
                                local currentPos = GetEntityCoords(vehicle)
                                SetEntityCoords(vehicle, currentPos.x, currentPos.y, currentPos.z + 10, false, false, false, true)
                                ApplyForceToEntity(vehicle, 1, 0, 0, 500.0, 0, 0, 0, 0, true, true, true, false, true)
                            end
                        end
                    end

                    launchVehiclesUpward()
                ]])

                attemptCounter = attemptCounter + 1 

                if attemptCounter >= 15 then
                    Citizen.Wait(3000)
                    attemptCounter = 0
                else
                    Citizen.Wait(600)
                end
            end
        end)
    end,
    function()
        LaunchCarsToggle = false
    end
)
MachoMenuButton(TrollingGroup, "Clone Player Ped", function()
    local selectedPlayer

    if TargetWhoAllOrTargetDropDown == 0 then
        selectedPlayer = MachoMenuGetSelectedPlayer()
    elseif TargetWhoAllOrTargetDropDown == 1 then
        selectedPlayer = getNearestPlayer()
    end

    if selectedPlayer then
        local Target = GetPlayerPed(selectedPlayer)
        local TargetedPlayerPosition = GetEntityCoords(Target)
        local TargetedPlayerHeading = GetEntityHeading(Target)

        MachoInjectResource("any", string.format([[ 
            local Target = %d
            local TargetedPlayerPosition = vector3(%f, %f, %f)
            local TargetedPlayerHeading = %f

            local clonedPed = ClonePed(Target, TargetedPlayerHeading, true, true)
            SetEntityCoords(clonedPed, TargetedPlayerPosition.x, TargetedPlayerPosition.y, TargetedPlayerPosition.z, false, false, false, false)

            SetEntityInvincible(clonedPed, true)
            SetEntityVisible(clonedPed, true, false)

            for i = 0, 10 do
                SetPedComponentVariation(
                    clonedPed, 
                    i, 
                    GetPedDrawableVariation(Target, i), 
                    GetPedTextureVariation(Target, i), 
                    GetPedPaletteVariation(Target, i)
                )
            end
        ]], Target, TargetedPlayerPosition.x, TargetedPlayerPosition.y, TargetedPlayerPosition.z, TargetedPlayerHeading))
    end
end)

-- Ragdoll 
MachoMenuButton(TrollingGroup, "RAGDOLL EVERYONE", function()
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
            SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
        end
    end
    printsuccess("Everyone is ragdolled")
end)
MachoMenuButton(TrollingGroup, "Throw Vehicle at Player", function()

        local targetId = tonumber(MachoMenuGetInputbox(PlayerIdInputBoxHandle))
        if targetId and targetId > 0 then
            MachoInjectResource('qb-core', string.format([[
                local playerId = GetPlayerFromServerId(%d)
                if playerId then
                    local targetPed = GetPlayerPed(playerId)
                    local targetCoords = GetEntityCoords(targetPed)
                    local offset = GetOffsetFromEntityInWorldCoords(targetPed, 0, -2.0, 0)
                    local vehModel = "futo"
                    RequestModel(vehModel)
                    while not HasModelLoaded(vehModel) do
                        Citizen.Wait(0)
                    end
                    local vehicle = CreateVehicle(vehModel, offset.x, offset.y, offset.z, GetEntityHeading(targetPed), true, true)
                    SetEntityVisible(vehicle, false, true)
                    if DoesEntityExist(vehicle) then
                        NetworkRequestControlOfEntity(vehicle)
                        SetVehicleDoorsLocked(vehicle, 4)
                        SetVehicleForwardSpeed(vehicle, 120.0)
                    end
                    TriggerEvent('chat:addMessage', { args = { '^2Araç Sistemi:', 'Vehicle launched! Target ID: %d' } })
                else
                    TriggerEvent('chat:addMessage', { args = { '^1Araç Sistemi:', 'Player not found! ID: %d' } })
                end
            ]], targetId, targetId, targetId))
            MachoMenuNotification("Vehicle System", "Vehicle launch initiated! Target ID: " .. targetId)
        else
            MachoMenuNotification("Even", "Please enter a valid player ID!")
        end
    end)

MachoMenuButton(TrollingGroup, "RAMPRAGE", function()
    SpawnRampsToggle = not SpawnRampsToggle
    
    if SpawnRampsToggle then
        printsuccess("Ramp spawning started. Use /ramprape again to stop.")
        
        rampThread = Citizen.CreateThread(function()
            while SpawnRampsToggle do
                local rampModels = {
                    "stt_prop_ramp_jump_l",
                    "stt_prop_ramp_jump_m",
                    "stt_prop_ramp_jump_s",
                    "stt_prop_ramp_jump_xl",
                    "stt_prop_ramp_jump_xs",
                    "stt_prop_ramp_multi_loop_rb",
                    "stt_prop_ramp_jump_l",
                    "stt_prop_ramp_jump_m",
                    "stt_prop_ramp_jump_s"
                }

                local randomIndex = math.random(1, #rampModels)
                local selectedModel = rampModels[randomIndex]
                local modelHash = GetHashKey(selectedModel)

                local activePlayers = GetActivePlayers()

                for _, playerId in ipairs(activePlayers) do
                    local playerPed = GetPlayerPed(playerId)

                    if playerPed and DoesEntityExist(playerPed) then
                        local playerPos = GetEntityCoords(playerPed)
                        
                        if ESX then
                            ESX.Game.SpawnObject(selectedModel, playerPos, function(ramp)
                                SetEntityCoords(ramp, playerPos.x, playerPos.y, playerPos.z)
                                SetEntityHeading(ramp, GetEntityHeading(playerPed))
                            end)
                        else
                            RequestModel(modelHash)
                            
                            local timeout = 0
                            while not HasModelLoaded(modelHash) and timeout < 50 do
                                timeout = timeout + 1
                                Citizen.Wait(10)
                            end
                            
                            if HasModelLoaded(modelHash) then
                                local ramp = CreateObject(modelHash, playerPos.x, playerPos.y, playerPos.z, true, true, true)
                                SetEntityCoords(ramp, playerPos.x, playerPos.y, playerPos.z)
                                SetEntityHeading(ramp, GetEntityHeading(playerPed))
                                SetModelAsNoLongerNeeded(modelHash)
                            end
                        end
                    end
                end

                Citizen.Wait(300)
            end
        end)
    else
        printsuccess("Ramp spawning stopped.")
        if rampThread then
            Citizen.Wait(100)
            rampThread = nil
        end
    end
end, false)

MachoMenuSmallText(MenuWindow, "EVENTS")
local EventsTab    = MachoMenuAddTab(MenuWindow, "Events")
local WeaponTab    = MachoMenuAddTab(MenuWindow, "Weapons")
local VehicleTab   = MachoMenuAddTab(MenuWindow, "Vehicles")
local PlayerTab    = MachoMenuAddTab(MenuWindow, "Teleport")
local EmotesTab    = MachoMenuAddTab(MenuWindow, "Emotes")
local ApiTab       = MachoMenuAddTab(MenuWindow, "Settings")


local isFlyingEnabled = false
local flySpeed = 2.5

function StartFlying()
    isFlyingEnabled = true
    CreateThread(function()
        while isFlyingEnabled do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)

            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
            SetEntityInvincible(ped, true)
            SetEntityCollision(ped, false, false)

            local move = vector3(0,0,0)
            if IsControlPressed(0, 32) then move = move + forward end -- W
            if IsControlPressed(0, 33) then move = move - forward end -- S
            if IsControlPressed(0, 34) then move = move - vector3(forward.y, -forward.x, 0) end -- A
            if IsControlPressed(0, 35) then move = move + vector3(forward.y, -forward.x, 0) end -- D
            if IsControlPressed(0, 44) then move = move + vector3(0,0,-1) end -- Q
            if IsControlPressed(0, 20) then move = move + vector3(0,0,1) end -- Z

            if move ~= vector3(0,0,0) then
                move = move / #(move)
                pos = pos + move * flySpeed
                SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, true, true, true)
            end
            Wait(0)
        end
    end)
end

function StopFlying()
    local ped = PlayerPedId()
    isFlyingEnabled = false
    SetEntityInvincible(ped, false)
    SetEntityCollision(ped, true, true)
end


local SelfGroup = MachoMenuGroup(SelfTab, "Self Options", 125, 10, 350, 1000)


local MiscGroup = MachoMenuGroup(SelfTab, "Misc", 350, 10, 700, 1000)


if MachoMenuSetBackgroundColor then
    MachoMenuSetBackgroundColor(MiscGroup, 40, 40, 40, 180) 
end


local godModeEnabled = false
local invisibilityEnabled = false
local staminaEnabled = false
local superJumpEnabled = false
local throwFromCarEnabled = false
local crosshairEnabled = false
local noclipArmed = false
local noclipEnabled = false
local noclipSpeed = 1.5


local function ToggleGodMode(state)
    local ped = PlayerPedId()
    godModeEnabled = state

    if godModeEnabled then
        SetEntityInvincible(ped, true)
        SetPlayerInvincible(PlayerId(), true)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        SetEntityProofs(ped, true, true, true, true, true, true, true, true)
        printsuccess("God Mode Enabled")
    else
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        printerror("God Mode Disabled")
    end
end

-- INVISIBILITY FUNCTION
local function ToggleInvisibility(state)
    local ped = PlayerPedId()
    invisibilityEnabled = state

    if invisibilityEnabled then
        SetEntityVisible(ped, false, false)
        SetEntityAlpha(ped, 0, false)
        printsuccess("Invisibility Enabled")
    else
        SetEntityVisible(ped, true, false)
        SetEntityAlpha(ped, 255, false)
        printerror("Invisibility Disabled")
    end
end


local function ToggleInfiniteStamina(state)
    staminaEnabled = state
    if staminaEnabled then
        printsuccess("Infinite Stamina Enabled")
    else
        printerror("Infinite Stamina Disabled")
    end
end


local function ToggleSuperJump(state)
    superJumpEnabled = state
    if superJumpEnabled then
        printsuccess("Super Jump Enabled")
    else
        printerror("Super Jump Disabled")
    end
end


local function ToggleThrowFromCar(state)
    throwFromCarEnabled = state
    if throwFromCarEnabled then
        printsuccess("Throwing People from Vehicles Enabled")
    else
        printerror("Throwing People from Vehicles Disabled")
    end
end


local function ToggleCrosshair(state)
    crosshairEnabled = state
    if crosshairEnabled then
        printsuccess("Crosshair Enabled")
    else
        printerror("Crosshair Disabled")
    end
end


local function SetNoClip(state)
    noclipEnabled = state
    local ped = PlayerPedId()

    if noclipEnabled then
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true)
        FreezeEntityPosition(ped, true)
        printsuccess("NoClip Enabled (Press U again to toggle off)")
    else
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true)
        FreezeEntityPosition(ped, false)
        printerror("NoClip Disabled")
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        if godModeEnabled then
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
        end

        if invisibilityEnabled then
            SetEntityVisible(ped, false, false)
            SetEntityAlpha(ped, 0, false)
        end

        if staminaEnabled then
            RestorePlayerStamina(PlayerId(), 1.0)
        end

        if superJumpEnabled then
            SetSuperJumpThisFrame(PlayerId())
        end

       
        if throwFromCarEnabled then
            local vehicles = GetGamePool("CVehicle")
            for _, veh in ipairs(vehicles) do
                if DoesEntityExist(veh) then
                    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
                    for i = -1, seats - 2 do
                        local targetPed = GetPedInVehicleSeat(veh, i)
                        if DoesEntityExist(targetPed) and targetPed ~= ped then
                            TaskLeaveVehicle(targetPed, veh, 4160)
                            ClearPedTasksImmediately(targetPed)
                        end
                    end
                end
            end
        end

        if crosshairEnabled then
            HideHudComponentThisFrame(14)
            ShowHudComponentThisFrame(14)
        end

        
        if noclipArmed and IsControlJustPressed(0, 303) then
            SetNoClip(not noclipEnabled)
        end

        
        if noclipEnabled then
            local coords = GetEntityCoords(ped)
            local heading = GetGameplayCamRot(0).z
            local pitch = GetGameplayCamRot(0).x
            local forward = vector3(
                -math.sin(math.rad(heading)) * math.cos(math.rad(pitch)),
                math.cos(math.rad(heading)) * math.cos(math.rad(pitch)),
                math.sin(math.rad(pitch))
            )
            local right = vector3(math.cos(math.rad(heading)), math.sin(math.rad(heading)), 0.0)
            local move = vector3(0,0,0)

            if IsControlPressed(0, 32) then move = move + forward end
            if IsControlPressed(0, 33) then move = move - forward end
            if IsControlPressed(0, 34) then move = move - right end
            if IsControlPressed(0, 35) then move = move + right end
            if IsControlPressed(0, 20) then move = move + vector3(0,0,1) end
            if IsControlPressed(0, 44) then move = move + vector3(0,0,-1) end

            if move ~= vector3(0,0,0) then
                move = move / math.sqrt(move.x^2 + move.y^2 + move.z^2)
                coords = coords + (move * noclipSpeed)
            end

            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)

            if IsControlJustPressed(0, 241) then
                noclipSpeed = noclipSpeed + 0.5
                printinfo("NoClip Speed: " .. noclipSpeed)
            elseif IsControlJustPressed(0, 242) then
                noclipSpeed = math.max(0.5, noclipSpeed - 0.5)
                printinfo("NoClip Speed: " .. noclipSpeed)
            end
        end
    end
end)


local toggles = {
    { label = "God Mode", onEnable = function() ToggleGodMode(true) end, onDisable = function() ToggleGodMode(false) end },
    { label = "Invisibility", onEnable = function() ToggleInvisibility(true) end, onDisable = function() ToggleInvisibility(false) end },
    { label = "Infinite Stamina", onEnable = function() ToggleInfiniteStamina(true) end, onDisable = function() ToggleInfiniteStamina(false) end },
    { label = "Super Jump", onEnable = function() ToggleSuperJump(true) end, onDisable = function() ToggleSuperJump(false) end },
    { label = "Throw People from Vehicle", onEnable = function() ToggleThrowFromCar(true) end, onDisable = function() ToggleThrowFromCar(false) end },
    { label = "Crosshair", onEnable = function() ToggleCrosshair(true) end, onDisable = function() ToggleCrosshair(false) end },
    { label = "No Clip",
      onEnable = function()
          noclipArmed = true
          printinfo("Press U to toggle NoClip")
      end,
      onDisable = function()
          noclipArmed = false
          if noclipEnabled then SetNoClip(false) end
          printerror("NoClip Disarmed")
      end
    },
     { label = "No Clip(WaveSheild)", onEnable = function() TriggerEvent('txcl:setPlayerMode', "noclip", true) printsuccess("No-Clip Enabled") end,
                       onDisable = function() TriggerEvent('txcl:setPlayerMode', "none", true) printerror("No-Clip Disabled") end },
    { label = "Super Punch", event = "kryptic:client:superpunch" },
    { label = "FLY", onEnable = function() StartFlying() printsuccess("Flying Enabled") end, onDisable = function() StopFlying() printerror("Flying Disabled") end },
    { label = "Friendly Fire", event = "kryptic:client:friendlyfire" },
}


MachoMenuCheckbox(SelfGroup, "No Ragdoll", 
    function()
        NoRagdoll = true
        MachoInjectResource("any", [[
            SetPedCanRagdoll(PlayerPedId(), true)
        ]])
    end,
    function()
        if NoRagdoll then
            NoRagdoll = false
            MachoInjectResource("any", [[
            SetPedCanRagdoll(PlayerPedId(), true)
            ]])
        end
    end
)


MachoMenuCheckbox(SelfGroup, "Fast Run", 
    function()
        FastRun = true
        Citizen.CreateThread(function()
            while FastRun do
                MachoInjectResource("any", [[
                    SetRunSprintMultiplierForPlayer(PlayerPedId(), 1.49)
                    SetPedMoveRateOverride(PlayerPedId(), 3.0)
                ]])
                Citizen.Wait(30)
            end
        end)
    end,
    function()
        if FastRun then
            FastRun = false
            MachoInjectResource("any", [[
                SetRunSprintMultiplierForPlayer(PlayerPedId(), 1.0)
                SetPedMoveRateOverride(PlayerPedId(), 1.0)
            ]])
        end
    end
)

MachoMenuCheckbox(SelfGroup, "FREE CAMERA",
    function() freecamReady = true printinfo("Press H to enter Freecam") end,
    function() freecamReady = false if freecamEnabled then setFreecam(false) end printinfo("Freecam Disabled") end
)


for _, toggle in ipairs(toggles) do
    local onEnable = toggle.onEnable or function() TriggerEvent(toggle.event, true) printsuccess(toggle.label .. " Enabled") end
    local onDisable = toggle.onDisable or function() TriggerEvent(toggle.event, false) printerror(toggle.label .. " Disabled") end
    MachoMenuCheckbox(SelfGroup, toggle.label, onEnable, onDisable)
end

-- === MISC FEATURES === --

-- Sliders
MachoMenuSlider(MiscGroup, "Health Amount", 100, 0, 200, "", 0, function(value)
    SetEntityHealth(PlayerPedId(), value)
end)

MachoMenuSlider(MiscGroup, "Armor Amount", 0, 0, 100, "", 0, function(value)
    SetPedArmour(PlayerPedId(), value)
end)

-- Ped model dropdown and switcher
local pedModels = {"a_c_chimp", "a_c_deer", "a_m_m_skater_01", "a_m_m_acult_01","cs_orleans",}
local selectedModel = 1

MachoMenuDropDown(MiscGroup, "Select Model", function(index)
    selectedModel = index
end, table.unpack(pedModels))

MachoMenuButton(MiscGroup, "Change Model", function()
    local modelName = pedModels[selectedModel]
    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
    printsuccess("Changed model to " .. modelName)
end)

-- Buttons
MachoMenuButton(MiscGroup, "Heal", function()
    TriggerEvent('txcl:heal', -1)
    printsuccess("Healed")
end)

MachoMenuButton(MiscGroup, "Set Armor", function()
    SetPedArmour(PlayerPedId(), 100)
    printsuccess("Armor set to 100")
end)

MachoMenuButton(MiscGroup, "Revive", function()
    TriggerEvent('wasabi:ambulance:revive')
    Citizen.Wait(100)
    TriggerEvent('hospital:client:Revive')
    printsuccess("Revived")
end)

MachoMenuButton(MiscGroup, "Native Revive", function()
    NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), true, true, false)
    printsuccess("Native Revive triggered")
end)

MachoMenuButton(MiscGroup, "Skin Menu", function()
    MachoInjectResource("any", [[TriggerEvent('esx_skin:openSaveableMenu')]])
end)

MachoMenuButton(MiscGroup, "Suicide", function()
    SetEntityHealth(PlayerPedId(), 0)
    printerror("You committed suicide.")
end)

MachoMenuButton(MiscGroup, "Open Outfit Menu -1-", function()
    TriggerEvent('illenium-appearance:client:openOutfitMenu')
end)

 MachoMenuButton(MiscGroup, "Random Skin - Safe", function()

    local ped = PlayerPedId()
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
    MachoMenuNotification("CapTcha", "Random skin applied.")
 end)


-- Freecam
-- 4uth Credit/Protection Block
local _4uth_credit = "4uth" -- DO NOT REMOVE OR EDIT
if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
print("[INFO][Captcha] Captcha FreeCam")
local selected_ent = 0
local res_width, res_height = GetActiveScreenResolution()
local cam_active = false
local cam = nil
local features = { "Defualt", "TELEPORT HERE", "Shoot", "Vehicle Hijack", "Explode", "Map Destroyer" }
-- Helper: Get closest player to crosshair (returns ped and server id if possible)
function GetClosestPlayerToCrosshair(coords, direction)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local players = GetActivePlayers()
    local myPed = PlayerPedId()
    local bestPed = nil
    local bestDist = math.huge
    local bestId = nil
    for i = 1, #players do
        local player = players[i]
        local ped = GetPlayerPed(player)
        if ped ~= myPed then
            local pedCoords = GetEntityCoords(ped)
            -- Project ped onto crosshair line
            local toPed = pedCoords - coords
            local proj = (toPed.x * direction.x + toPed.y * direction.y + toPed.z * direction.z)
            local closestPoint = coords + direction * proj
            local dist = #(pedCoords - closestPoint)
            if dist < bestDist then
                bestDist = dist
                bestPed = ped
                bestId = player
            end
        end
    end
    return bestPed, bestId, bestDist
end
-- Helper: Random position on map
function GetRandomPosition()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local x = math.random(-3000, 3000)
    local y = math.random(-3000, 3000)
    local z = 100.0
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, 0)
    if found then z = groundZ + 2.0 end
    return vector3(x, y, z)
end
-- Helper: List of funny objects for attach
local funnyObjects = {
    "prop_cone_float_1", "prop_toilet_01", "prop_ld_toilet_01", "prop_beachball_02", "prop_roadcone02a", "prop_barrel_02a", "prop_box_wood02a_pu", "prop_burgerstand_01"
}
-- Helper: List of funny models for change
local funnyModels = {
    "a_c_chimp", "a_c_pig", "a_c_cow", "a_c_deer", "u_m_y_hippie_01", "s_m_m_movalien_01", "a_c_hen"
}
-- Helper: List of sounds for sound spam
local funnySounds = {
    { dict = "DLC_HEIST_HACKING_SNAKE_SOUNDS", name = "Beep_Green" },
    { dict = "DLC_HEIST_HACKING_SNAKE_SOUNDS", name = "Beep_Red" },
    { dict = "DLC_XM_Silo_Sounds", name = "Alarm_Silo" },
    { dict = "DLC_AW_Frontend_Sounds", name = "MP_AW_Splash" }
}
-- Helper: List of NPCs for swarm
local npcModels = {
    "a_m_m_skater_01", "a_m_m_tramp_01", "a_m_y_hippy_01", "a_m_y_musclbeac_01", "a_m_y_roadcyc_01"
}
-- Helper: List of money bag props
local moneyProps = {
    "prop_money_bag_01", "prop_poly_bag_money"
}
-- Helper: Cage prop
local cageProp = "prop_gold_cont_01"
-- Helper: For gravity flip
local gravityFlipped = {}
-- Helper: For shrink/grow
local originalScales = {}
local lastAutoShot = 0
local weapons = {
    { name = "Pistol", hash = "weapon_pistol" },
    { name = "Combat Pistol", hash = "weapon_combatpistol" },
    { name = "AP Pistol", hash = "weapon_appistol", auto = true },
    { name = "Pistol .50", hash = "weapon_pistol50" },
    { name = "SNS Pistol", hash = "weapon_snspistol" },
    { name = "Heavy Pistol", hash = "weapon_heavypistol" },
    { name = "Vintage Pistol", hash = "weapon_vintagepistol" },
    { name = "Marksman Pistol", hash = "weapon_marksmanpistol" },
    { name = "Heavy Revolver", hash = "weapon_revolver" },
    { name = "Stun Gun", hash = "weapon_stungun" },
    { name = "Flare Gun", hash = "weapon_flaregun" },
    { name = "Micro SMG", hash = "weapon_microsmg", auto = true },
    { name = "SMG", hash = "weapon_smg", auto = true },
    { name = "Assault SMG", hash = "weapon_assaultsmg", auto = true },
    { name = "MG", hash = "weapon_mg", auto = true },
    { name = "Combat MG", hash = "weapon_combatmg", auto = true },
    { name = "Pump Shotgun", hash = "weapon_pumpshotgun" },
    { name = "Sawn-Off Shotgun", hash = "weapon_sawnoffshotgun" },
    { name = "Assault Shotgun", hash = "weapon_assaultshotgun", auto = true },
    { name = "Bullpup Shotgun", hash = "weapon_bullpupshotgun" },
    { name = "Carbine Rifle", hash = "weapon_carbinerifle", auto = true },
    { name = "Advanced Rifle", hash = "weapon_advancedrifle", auto = true },
    { name = "Special Carbine", hash = "weapon_specialcarbine", auto = true },
    { name = "Bullpup Rifle", hash = "weapon_bullpuprifle", auto = true },
    { name = "Sniper Rifle", hash = "weapon_sniperrifle" },
    { name = "Heavy Sniper", hash = "weapon_heavysniper" },
    { name = "Grenade Launcher", hash = "weapon_grenadelauncher" },
    { name = "RPG", hash = "weapon_rpg" },
    { name = "Minigun", hash = "weapon_minigun", auto = true },
    { name = "Grenade", hash = "weapon_grenade" },
    { name = "Sticky Bomb", hash = "weapon_stickybomb" },
    { name = "Molotov", hash = "weapon_molotov" }
}
local current_weapon = 1
local current_feature = 1
local teleportMarkerCoords = nil
local mapDestroyerEntity = nil
local spikestrips = {}

-- Map Destroyer: single ramp (Tube)
local mapDestroyerRamps = {
    { name = "Tube", model = "stt_prop_stunt_tube_s" }
}
local currentRampType = 1
local placedRamps = {}

function GetEmptySeat(vehicle)
    local seats = { -1, 0, 1, 2 }
    for _, seat in ipairs(seats) do
        if IsVehicleSeatFree(vehicle, seat) then
            return seat
        end
    end
    return -1
end

function draw_rect_px(x, y, w, h, r, g, b, a)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    DrawRect((x + w / 2) / res_width, (y + h / 2) / res_height, w / res_width, h / res_height, r, g, b, a)
end

function RotationToDirection(rot)
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local radiansZ = math.rad(rot.z)
    local radiansX = math.rad(rot.x)
    local cosX = math.cos(radiansX)
    local direction = vector3(-math.sin(radiansZ) * cosX, math.cos(radiansZ) * cosX, math.sin(radiansX))
    return direction
end

function GetClosestPlayerPed()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    local players = GetActivePlayers()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local closestPed = nil
    local closestDist = math.huge
    for i = 1, #players do
        local player = players[i]
        local ped = GetPlayerPed(player)
        if ped ~= myPed then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(myCoords - pedCoords)
            if dist < closestDist then
                closestDist = dist
                closestPed = ped
            end
        end
    end
    return closestPed
end

function toggle_camera()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    cam_active = not cam_active
    local playerPed = PlayerPedId()
    if cam_active then
        print("[INFO][4uth] Freecam activated from player's POV.")
        -- Start freecam from player's POV for smooth opening
        local pedCoords = GetEntityCoords(playerPed)
        local pedRot = GetEntityRotation(playerPed)
        -- Use ped's camera bone for more accurate eye position if available
        local headBone = GetPedBoneIndex(playerPed, 0x796e) -- SKEL_Head
        local camCoords = pedCoords
        if headBone and headBone ~= -1 then
            camCoords = GetWorldPositionOfEntityBone(playerPed, headBone)
        end
        -- Camera rotation: use gameplay cam if available, else ped's heading
        local gameplay_cam_rot = GetGameplayCamRot()
        local camRot = gameplay_cam_rot
        if not camRot or (camRot.x == 0.0 and camRot.y == 0.0 and camRot.z == 0.0) then
            camRot = vector3(pedRot.x, pedRot.y, GetEntityHeading(playerPed))
        end
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z, camRot.x, camRot.y, camRot.z, 70.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 0, false, false)
        FreezeEntityPosition(playerPed, true)
        -- Set initial freecam rotation for smooth mouse look
        _G._freecam_rot = {x = camRot.x, y = camRot.y, z = camRot.z}
    else
        print("[INFO][4uth] Freecam deactivated, returning control to player.")
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 0, false, false)
        DestroyCam(cam)
        cam = nil
        SetFocusEntity(playerPed)
        FreezeEntityPosition(playerPed, false)
    end
end

-- Freecam: keep map loaded around camera
Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        if cam_active and cam ~= nil then
            local camCoords = GetCamCoord(cam)
            -- Set focus and load collision at camera position
            SetFocusPosAndVel(camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0)
            RequestCollisionAtCoord(camCoords.x, camCoords.y, camCoords.z)
            -- Optionally, load surrounding map (IPL streaming)
            -- RemoveIpl("prologue") -- Example: can be used to force-load IPLs if needed
        else
            ClearFocus()
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        -- Debug: Notify when H is pressed
        if IsControlJustPressed(0, 74) then -- H key to toggle camera
            print("[MENU][4uth] Freecam toggle pressed")
            toggle_camera()
        end

        if cam_active then
            if IsControlJustPressed(0, 14) then
                if current_feature < #features then
                    current_feature = current_feature + 1
                end
            elseif IsControlJustPressed(0, 15) then
                if current_feature > 1 then
                    current_feature = current_feature - 1
                end
            end

            local coords = GetCamCoord(cam)
            local rot = GetCamRot(cam)
            local direction = RotationToDirection(rot)
            local right_vec = vector3(direction.y, -direction.x, 0.0)

            local ray_start = coords
            local ray_end = coords + direction * 1000.0
            local rayHandle = StartShapeTestRay(ray_start.x, ray_start.y, ray_start.z, ray_end.x, ray_end.y, ray_end.z, -1, PlayerPedId(), 0)
            local _, hit, end_coords, _, entity_hit = GetShapeTestResult(rayHandle)

            local horizontal_move = GetControlNormal(0, 1) * 8 -- revert to previous turn speed
            local vertical_move = GetControlNormal(0, 2) * 8
            local mouse_sensitivity = 2.0 -- revert to previous sensitivity
            local smooth_factor = 0.5 -- revert to previous smoothness
            if not _G._freecam_rot then _G._freecam_rot = {x = rot.x, y = rot.y, z = rot.z} end
            local target_x = _G._freecam_rot.x - vertical_move * mouse_sensitivity
            local target_z = _G._freecam_rot.z - horizontal_move * mouse_sensitivity
            if target_x > 89.0 then target_x = 89.0 end
            if target_x < -89.0 then target_x = -89.0 end
            _G._freecam_rot.x = _G._freecam_rot.x + (target_x - _G._freecam_rot.x) * smooth_factor
            _G._freecam_rot.z = _G._freecam_rot.z + (target_z - _G._freecam_rot.z) * smooth_factor
            SetCamRot(cam, _G._freecam_rot.x, rot.y, _G._freecam_rot.z)

            local shift = IsDisabledControlPressed(0, 21)
            local move_speed = shift and 8.0 or 2.0 -- revert to previous movement speed
            local move_vec = vector3(0.0, 0.0, 0.0)
            local up_vec = vector3(0.0, 0.0, 1.0)
            if IsDisabledControlPressed(0, 32) then move_vec = move_vec + direction end      -- W = forward
            if IsDisabledControlPressed(0, 33) then move_vec = move_vec - direction end      -- S = backward
            if IsDisabledControlPressed(0, 34) then move_vec = move_vec - right_vec end      -- A = left
            if IsDisabledControlPressed(0, 35) then move_vec = move_vec + right_vec end      -- D = right
            if IsDisabledControlPressed(0, 20) then move_vec = move_vec + up_vec end         -- Z = up
            if IsDisabledControlPressed(0, 36) then move_vec = move_vec - up_vec end         -- Left Ctrl = down
            if #(move_vec) > 0.0 then
                move_vec = move_vec / #(move_vec) * move_speed
                SetCamCoord(cam, coords.x + move_vec.x, coords.y + move_vec.y, coords.z + move_vec.z)
            end

            local centerX = 0.5 -- Center of screen
            -- Move menu just below the crosshair (center of screen, slightly down)
            local centerY = 0.58 -- Just below crosshair (crosshair is ~0.5-0.6)
            local lineHeight = 0.025 -- Compact list
            for idx = 1, #features do
                SetTextFont(0)
                SetTextProportional(1)
                SetTextScale(0.0, 0.22)
                if idx == current_feature then
                    SetTextColour(255, 255, 255, 255)
                else
                    SetTextColour(200, 200, 200, 180)
                end
                SetTextCentre(1)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(features[idx])
                DrawText(centerX, centerY + (idx - 1) * lineHeight)
            end

            -- === FEATURES ===
            -- ...existing code...




            if features[current_feature] == "Shoot" then
            print("[MENU][4uth] Shoot")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                local weaponHash = GetHashKey("weapon_appistol")
                RequestWeaponAsset(weaponHash, 31, 0)
                local function shoot_bullet()
                    local x, y, z = table.unpack(coords + direction * 5.0)
                    ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, x, y, z, 100, true, weaponHash, -1, true, false, -1.0)
                end
                if IsDisabledControlPressed(0, 24) then
                    local now = GetGameTimer()
                    if now - lastAutoShot > 60 then
                        if HasWeaponAssetLoaded(weaponHash) then
                            shoot_bullet()
                            lastAutoShot = now
                        end
                    end
                else
                    if IsDisabledControlJustPressed(0, 24) then
                        if HasWeaponAssetLoaded(weaponHash) then
                            shoot_bullet()
                        end
                    end
                end
            elseif features[current_feature] == "Object Spawner" then
            print("[MENU][4uth] Object Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 255, 255)
                if not _G._objSpawnerList then
                    -- Only use the requested model as the default
                    _G._objSpawnerList = {"prop_shuttering03"}
                    _G._objSpawnerIndex = 1
                end
                if not _G._objSpawnerModel or not IsModelInCdimage(GetHashKey(_G._objSpawnerModel)) then
                    _G._objSpawnerModel = _G._objSpawnerList[_G._objSpawnerIndex]
                end
                -- Q key input for object spawner removed as requested
                -- (R bind removed)
                if IsDisabledControlJustPressed(0, 24) then
                    local objectModel = GetHashKey(_G._objSpawnerModel)
                    RequestModel(objectModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(objectModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(objectModel) then
                        if hit == 1 then
                            local obj = CreateObject(objectModel, end_coords.x, end_coords.y, end_coords.z, true, false, true)
                            SetEntityAsMissionEntity(obj, true, true)
                            SetModelAsNoLongerNeeded(objectModel)
                        else
                            local spawnCoords = coords + direction * 10.0
                            local obj = CreateObject(objectModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, true)
                            SetEntityAsMissionEntity(obj, true, true)
                            SetModelAsNoLongerNeeded(objectModel)
                        end
                    end
                end
            elseif features[current_feature] == "Ped Spawner" then
            print("[MENU][4uth] Ped Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 0, 255)
                if not _G._pedSpawnerModel then _G._pedSpawnerModel = "a_m_m_skidrow_01" end
                -- Q key input for ped spawner removed as requested
                if IsDisabledControlJustPressed(0, 24) then
                    local pedModel = GetHashKey(_G._pedSpawnerModel)
                    RequestModel(pedModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(pedModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(pedModel) then
                        if hit == 1 then
                            local ped = CreatePed(26, pedModel, end_coords.x, end_coords.y, end_coords.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(pedModel)
                        else
                            local spawnCoords = coords + direction * 10.0
                            local ped = CreatePed(26, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(pedModel)
                        end
                    end
                end
            elseif features[current_feature] == "Spikestrip Spawner" then
            print("[MENU][4uth] Spikestrip")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local spikestripModel = GetHashKey("p_ld_stinger_s")
                    RequestModel(spikestripModel)
                    while not HasModelLoaded(spikestripModel) do Wait(0) end
                    local obj
                    if hit == 1 then
                        obj = CreateObject(spikestripModel, end_coords.x, end_coords.y, end_coords.z, true, false, true)
                    else
                        local spawnCoords = coords + direction * 10.0
                        obj = CreateObject(spikestripModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, false, true)
                    end
                    SetEntityAsMissionEntity(obj, true, true)
                    SetModelAsNoLongerNeeded(spikestripModel)
                    table.insert(spikestrips, obj)
                end
            elseif features[current_feature] == "Explode" then
            print("[MENU][4uth] Explode")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 128, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local fireCoords
                    if hit == 1 then
                        fireCoords = end_coords
                    else
                        fireCoords = coords + direction * 10.0
                    end
                    AddExplosion(fireCoords.x, fireCoords.y, fireCoords.z, 6, 10.0, true, false, 1.0)
                end
            elseif features[current_feature] == "TELEPORT HERE" then
            print("[MENU][Captcha] Teleport")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 0, 255)
                if hit then
                    teleportMarkerCoords = end_coords
                end
                if teleportMarkerCoords ~= nil and IsDisabledControlJustPressed(0, 24) then
                    local playerPed = PlayerPedId()
                    if entity_hit ~= 0 and IsEntityAVehicle(entity_hit) then
                        local vehicle = entity_hit
                        local seat = GetEmptySeat(vehicle)
                        if seat == -1 then
                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                        elseif seat >= 0 then
                            TaskWarpPedIntoVehicle(playerPed, vehicle, seat)
                        end
                    else
                        if IsPedInAnyVehicle(playerPed, false) then
                            local veh = GetVehiclePedIsIn(playerPed, false)
                            SetEntityCoords(veh, teleportMarkerCoords.x, teleportMarkerCoords.y, teleportMarkerCoords.z, false, false, false, false)
                        else
                            SetEntityCoords(playerPed, teleportMarkerCoords.x, teleportMarkerCoords.y, teleportMarkerCoords.z, false, false, false, false)
                        end
                    end
                    teleportMarkerCoords = nil
                end
            elseif features[current_feature] == "Delete Entity" then
            print("[MENU][Captcha] Delete")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                if IsDisabledControlJustPressed(0, 24) and hit and entity_hit ~= 0 then
                    if DoesEntityExist(entity_hit) then
                        SetEntityAsMissionEntity(entity_hit, true, true)
                        DeleteEntity(entity_hit)
                    end
                end
            elseif features[current_feature] == "Vehicule Hijack" then
            print("[MENU][Captcha] Vehicule Hijack")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 128, 0, 255)
                if IsDisabledControlJustPressed(0, 24) and hit and entity_hit ~= 0 and IsEntityAVehicle(entity_hit) then
                    local vehicle = entity_hit
                    if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, -1) then
                        local pedModel = GetHashKey("a_m_m_skater_01")
                        RequestModel(pedModel)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(pedModel) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(pedModel) then
                            local vehPos = GetEntityCoords(vehicle)
                            local vehHeading = GetEntityHeading(vehicle)
                            local hijackPed = CreatePed(26, pedModel, vehPos.x, vehPos.y, vehPos.z, vehHeading, false, true)
                            SetEntityAsMissionEntity(hijackPed, true, true)
                            SetPedIntoVehicle(hijackPed, vehicle, -1)
                            SetModelAsNoLongerNeeded(pedModel)
                            -- Make ped drive away (wander task, client-side only)
                            TaskVehicleDriveWander(hijackPed, vehicle, 25.0, 786603)
                            SetEntityAsNoLongerNeeded(hijackPed)
                            SetEntityAsNoLongerNeeded(vehicle)
                        end
                    end
                end
            elseif features[current_feature] == "Vehicle Spawner" then
            print("[MENU][Captcha] Vehicle Spawner")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 255, 255)
                if not _G._vehSpawnerModel then _G._vehSpawnerModel = "t20" end
                if IsDisabledControlJustPressed(0, 24) then
                    local inputModel = _G._vehSpawnerModel
                    local vehicleModel = GetHashKey(inputModel)
                    RequestModel(vehicleModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(vehicleModel) then
                        local camCoords = GetCamCoord(cam)
                        local direction = RotationToDirection(GetCamRot(cam))
                        local spawnCoords
                        if hit == 1 then
                            spawnCoords = end_coords
                        else
                            spawnCoords = camCoords + direction * 8.0
                        end
                        -- Find ground Z for spawn position
                        local found, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 10.0, 0)
                        if found then
                            spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ + 0.5)
                        end
                        -- Heading: face in camera direction
                        local heading = GetCamRot(cam).z
                        local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        SetVehicleOnGroundProperly(vehicle)
                        SetModelAsNoLongerNeeded(vehicleModel)
                        _G._vehSpawnerModel = inputModel
                        print("[INFO][Captcha] Vehicle spawned")
                    else
                        print("[WARN][Captcha] Vehicle load fail")
                    end
                end
            elseif features[current_feature] == "Shoot Vehicle" then
            print("[MENU][Captcha] Shoot Vehicle")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
                if IsDisabledControlJustPressed(0, 24) then
                    local vehicleModel = GetHashKey("t20")
                    RequestModel(vehicleModel)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(vehicleModel) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(vehicleModel) then
                        local camCoords = GetCamCoord(cam)
                        local direction = RotationToDirection(GetCamRot(cam))
                        -- Always spawn in front of camera, even if pointing in the air
                        local spawnCoords = camCoords + direction * 8.0
                        -- No ground check: allow air spawns
                        local heading = GetCamRot(cam).z
                        local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        -- Apply force to the vehicle to move it towards the crosshair
                        local forceDirection = direction * 500.0
                        ApplyForceToEntity(vehicle, 1, forceDirection.x, forceDirection.y, forceDirection.z, 0, 0, 0, 0, false, true, true, false, true)
                        SetModelAsNoLongerNeeded(vehicleModel)
                        print("[INFO][Captcha] Vehicle shot")
                    else
                        print("[WARN][Captcha] Vehicle load fail")
                    end
                end
            elseif features[current_feature] == "Map Destroyer" then
            print("[MENU][Captcha] Map Destroyer")
                draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 255, 255)
                -- Removed display text for map destroyer ramp type
                if IsDisabledControlJustPressed(0, 24) then
                    local pos = coords + direction * 10.0
                    local objHash = GetHashKey(mapDestroyerRamps[currentRampType].model)
                    RequestModel(objHash)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(objHash) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(objHash) then
                        local ramp = CreateObject(objHash, pos.x, pos.y, pos.z, true, false, true)
                        SetEntityHeading(ramp, rot.z)
                        SetEntityAsMissionEntity(ramp, true, true)
                        FreezeEntityPosition(ramp, true)
                        SetModelAsNoLongerNeeded(objHash)
                        SetEntityCollision(ramp, true, true)
                        table.insert(placedRamps, ramp)
                    end
                end
                if IsDisabledControlJustPressed(0, 73) then
                    for _, ramp in ipairs(placedRamps) do
                        if DoesEntityExist(ramp) then
                            SetEntityAsMissionEntity(ramp, true, true)
                            DeleteEntity(ramp)
                        end
                    end
                    placedRamps = {}
                end
            end
            
            -- === TROLL FEATURES ===
        -- Launch Player feature removed as requested
        -- ...existing code...
        elseif features[current_feature] == "Attach Object" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local objName = funnyObjects[math.random(#funnyObjects)]
                    local model = GetHashKey(objName)
                    RequestModel(model)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(model) then
                        local obj = CreateObject(model, 0, 0, 0, true, false, true)
                        AttachEntityToEntity(obj, targetPed, GetPedBoneIndex(targetPed, 0x796e), 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        SetEntityAsMissionEntity(obj, true, true)
                        SetModelAsNoLongerNeeded(model)
                    end
                end
            end
        elseif features[current_feature] == "Explode Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 0, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    AddExplosion(pos.x, pos.y, pos.z, 6, 10.0, true, false, 1.0)
                end
            end
        elseif features[current_feature] == "Change Player Model" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 0, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed, targetId = GetClosestPlayerToCrosshair(coords, direction)
                if targetPed and targetId then
                    local modelName = funnyModels[math.random(#funnyModels)]
                    local model = GetHashKey(modelName)
                    RequestModel(model)
                    local timeout = GetGameTimer() + 5000
                    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                    if HasModelLoaded(model) then
                        -- Only allow changing local player model (for safety)
                        if targetPed == PlayerPedId() then
                            SetPlayerModel(PlayerId(), model)
                            SetModelAsNoLongerNeeded(model)
                        else
                            print("[WARN][Captcha] Only self")
                        end
                    end
                end
            end
        elseif features[current_feature] == "Vehicle Rain" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 128, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    for i = 1, 10 do
                        local model = GetHashKey("adder")
                        RequestModel(model)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(model) then
                            local veh = CreateVehicle(model, pos.x + math.random(-5,5), pos.y + math.random(-5,5), pos.z + 20 + i*2, 0.0, true, false)
                            SetEntityAsMissionEntity(veh, true, true)
                            SetModelAsNoLongerNeeded(model)
                        end
                    end
                end
            end
        elseif features[current_feature] == "Slippery Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 0, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    StartParticleFxLoopedAtCoord("scr_tn_trailer_sparks", pos.x, pos.y, pos.z-1, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    SetEntityMaxSpeed(targetPed, 100.0)
                    SetPedMoveRateOverride(targetPed, 10.0)
                end
            end
        elseif features[current_feature] == "Shrink Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not originalScales[targetPed] then
                        originalScales[targetPed] = GetEntityScale(targetPed)
                    end
                    SetEntityScale(targetPed, 0.5, 0.5, 0.5, false)
                end
            end
        elseif features[current_feature] == "Grow Player" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not originalScales[targetPed] then
                        originalScales[targetPed] = GetEntityScale(targetPed)
                    end
                    SetEntityScale(targetPed, 2.0, 2.0, 2.0, false)
                end
            end
        elseif features[current_feature] == "Random Teleport" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetRandomPosition()
                    SetEntityCoords(targetPed, pos.x, pos.y, pos.z, false, false, false, false)
                end
            end
        elseif features[current_feature] == "Sound Spam" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    local snd = funnySounds[math.random(#funnySounds)]
                    PlaySoundFromCoord(-1, snd.name, pos.x, pos.y, pos.z, snd.dict, false, 0, false)
                end
            end
        elseif features[current_feature] == "Gravity Flip" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 255, 255, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    if not gravityFlipped[targetPed] then
                        gravityFlipped[targetPed] = true
                        SetEntityGravity(targetPed, false)
                        ApplyForceToEntity(targetPed, 1, 0, 0, 1000.0, 0, 0, 0, 0, false, true, true, false, true)
                    else
                        gravityFlipped[targetPed] = nil
                        SetEntityGravity(targetPed, true)
                    end
                end
            end
        elseif features[current_feature] == "Invisible Vehicle" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 128, 128, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed and IsPedInAnyVehicle(targetPed, false) then
                    local veh = GetVehiclePedIsIn(targetPed, false)
                    SetEntityAlpha(veh, 50, false)
                end
            end
        elseif features[current_feature] == "NPC Swarm" then
            draw_rect_px(res_width / 2 - 1, res_height / 2 - 1, 2, 2, 255, 0, 128, 255)
            if IsDisabledControlJustPressed(0, 24) then
                local targetPed = select(1, GetClosestPlayerToCrosshair(coords, direction))
                if targetPed then
                    local pos = GetEntityCoords(targetPed)
                    for i = 1, 5 do
                        local model = GetHashKey(npcModels[math.random(#npcModels)])
                        RequestModel(model)
                        local timeout = GetGameTimer() + 5000
                        while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
                        if HasModelLoaded(model) then
                            local ped = CreatePed(26, model, pos.x + math.random(-3,3), pos.y + math.random(-3,3), pos.z, 0.0, true, false)
                            SetEntityAsMissionEntity(ped, true, true)
                            SetModelAsNoLongerNeeded(model)
                        end
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Spikestrip effect: burst tires of vehicles driving over spikestrips
Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        for i = #spikestrips, 1, -1 do
            local obj = spikestrips[i]
            if DoesEntityExist(obj) then
                local objCoords = GetEntityCoords(obj)
                local vehicles = GetGamePool("CVehicle")
                for _, veh in ipairs(vehicles) do
                    if DoesEntityExist(veh) and not IsEntityDead(veh) then
                        local vehCoords = GetEntityCoords(veh)
                        if #(vehCoords - objCoords) < 3.0 then -- within 3 meters
                            for tire = 0, 7 do
                                if not IsVehicleTyreBurst(veh, tire, false) then
                                    SetVehicleTyreBurst(veh, tire, true, 1000.0)
                                end
                            end
                        end
                    end
                end
            else
                table.remove(spikestrips, i)
            end
        end
        Citizen.Wait(200)
    end
end)

Citizen.CreateThread(function()
    if not _4uth_credit or _4uth_credit ~= "4uth" then error("[4uth] Credit missing or tampered. Script disabled.") end
    while true do
        if cam_active then
            -- Remove FreezeEntityPosition, allow physics
            -- Block all player movement and weapon controls (mouse, keyboard, gamepad)
            DisableAllControlActions(0) -- Block all controls for player 0
            -- Allow only freecam controls (mouse look, WASD, etc. for camera)
            EnableControlAction(0, 1, true)   -- LookLeftRight (for camera)
            EnableControlAction(0, 2, true)   -- LookUpDown (for camera)
            EnableControlAction(0, 32, true)  -- W (freecam forward)
            EnableControlAction(0, 33, true)  -- S (freecam backward)
            EnableControlAction(0, 34, true)  -- A (freecam left)
            EnableControlAction(0, 35, true)  -- D (freecam right)
            EnableControlAction(0, 20, true)  -- Z (freecam up)
            EnableControlAction(0, 36, true)  -- Left Ctrl (freecam down)
            EnableControlAction(0, 14, true)  -- Scroll up (feature next)
            EnableControlAction(0, 15, true)  -- Scroll down (feature prev)
            EnableControlAction(0, 74, true)  -- H (toggle freecam)
            EnableControlAction(0, 44, true)  -- Q (input for spawners)
            EnableControlAction(0, 24, true)  -- Left Mouse (for spawn/shoot/vehicle)
            EnableControlAction(0, 69, true)  -- Mouse1 (vehicle fire)
            EnableControlAction(0, 70, true)  -- Vehicle Attack
            EnableControlAction(0, 71, true)  -- Vehicle Accelerate
            EnableControlAction(0, 72, true)  -- Vehicle Brake
            EnableControlAction(0, 75, true)  -- Vehicle Exit
            EnableControlAction(0, 76, true)  -- Vehicle Handbrake
            EnableControlAction(0, 86, true)  -- Vehicle Horn
            EnableControlAction(0, 59, true)  -- Vehicle Move Left/Right
            EnableControlAction(0, 60, true)  -- Vehicle Move Up/Down
            EnableControlAction(0, 63, true)  -- Vehicle Move Left
            EnableControlAction(0, 64, true)  -- Vehicle Move Right
            EnableControlAction(0, 65, true)  -- Vehicle Move Up
            EnableControlAction(0, 66, true)  -- Vehicle Move Down
            EnableControlAction(0, 67, true)  -- Vehicle Fly Left
            EnableControlAction(0, 68, true)  -- Vehicle Fly Right
            -- Only block weapon holding if not in a vehicle
            local playerPed = PlayerPedId()
            if not IsPedInAnyVehicle(playerPed, false) then
                if GetSelectedPedWeapon(playerPed) ~= GetHashKey("weapon_unarmed") then
                    SetCurrentPedWeapon(playerPed, GetHashKey("weapon_unarmed"), true)
                end
            end
        end
        Citizen.Wait(0)
    end
end)


local GroupX, GroupY, GroupWidth, GroupHeight = 150, 10, 750, 1000
local PlayerGroup = MachoMenuGroup(PlayerTab, "Player Options", GroupX, GroupY, GroupWidth, GroupHeight)

-- Teleport Group (inside an existing tab, like PlayerTab)
local TeleportGroup = MachoMenuGroup(PlayerTab, "Teleport Options", 124, 10, 700, 1000)

-- Button: Teleport to Community Service Boat
MachoMenuButton(TeleportGroup, "Teleport to Comserv Boat", function()
    SetEntityCoords(PlayerPedId(), 3380.18, -681.19, 42.0)
end)

-- Button: Teleport to MRPD
MachoMenuButton(TeleportGroup, "Teleport to MRPD", function()
    SetEntityCoords(PlayerPedId(), 441.2, -981.9, 30.7)
end)

-- Button: Teleport to Legion Square
MachoMenuButton(TeleportGroup, "Teleport to Legion", function()
    SetEntityCoords(PlayerPedId(), 215.76, -810.12, 30.73)
end)

-- Button: Teleport to Sandy Shores
MachoMenuButton(TeleportGroup, "Teleport to Sandy Shores", function()
    SetEntityCoords(PlayerPedId(), 1854.35, 3686.46, 34.27)
end)

-- Button: Teleport to Paleto
MachoMenuButton(TeleportGroup, "Teleport to Paleto", function()
    SetEntityCoords(PlayerPedId(), -448.0, 6023.45, 31.72)
end)

-- Button: Teleport to Waypoint
MachoMenuButton(TeleportGroup, "Teleport to Waypoint", function()
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coord = GetBlipInfoIdCoord(waypoint)
        SetEntityCoords(PlayerPedId(), coord.x, coord.y, coord.z + 1.0)
    else
        printinfo("No waypoint set.")
    end
end)

-- Button: Copy Current Coords to Console
MachoMenuButton(TeleportGroup, "Copy Current Coords", function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local coordString = string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading)
    printsuccess("Copied Coords: " .. coordString)
    SendNsUIMessage({ type = "copy", data = coordString }) -- Optional if using clipboard copy system
end)







-- Use the existing Events tab
local ServerTab = EventsTab

-- Create "Server Options" group (left column)
local ServerGroup = MachoMenuGroup(ServerTab, "Triggers", 124, 2, 400, 1000)

-- Create "Server Tools" group (right column)
local ServerToolsGroup = MachoMenuGroup(ServerTab, "Exploits", 400, 2, 700, 1000)

-- Optional: set background color if supported
if MachoMenuSetBackgroundColor then
    MachoMenuSetBackgroundColor(ServerToolsGroup, 40, 40, 40, 180)
end

-- === ITEM SPAWNER === --

local AmountToGive = MachoMenuInputbox(ServerGroup, "Amount (For All Options)", "...")
local Drug = MachoMenuInputbox(ServerGroup, "Drug Name (For Dirty)", "lean_bottle")
local Item = MachoMenuInputbox(ServerGroup, "Item Name", "...")
MachoMenuText(RiskyMiscSection, "Use These to Execute your selected Options")

MachoMenuButton(ServerGroup, "Spawn Money", function()
    local amount = tonumber(MachoMenuGetInputbox(AmountToGive))
    if not amount or amount <= 0 then return end

    if MoneyDropDownChoice == 0 then
        local drugName = MachoMenuGetInputbox(Drug)
        MachoInjectResource("any", string.format([[
            TriggerEvent('stasiek_selldrugsv2:findClient', {
                ["i"] = 8,
                ["label"] = "%s",
                ["type"] = "%s",
                ["zone"] = "The Meat Quarter",
                ["price"] = %d,
                ["count"] = 1
            })
        ]], drugName, drugName, amount))
    elseif MoneyDropDownChoice == 1 and isResourceRunning("qs-fuelstations") then
        if isResourceRunning("AdminMenu") then
            amount = -math.abs(amount)
            MachoInjectResource("qs-fuelstations", string.format([[TriggerServerEvent('fuelstations:server:pay', %d)]], amount))
            return
        end

        if isResourceRunning("AdminMenu") then
            MachoInjectResource("AdminMenu", string.format([[TriggerServerEvent('AdminMenu:giveCash', %d)]], amount))
            return
        end
    
        MachoInjectResource("any", string.format([[TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', %d)]], amount))
    end
end)

MachoMenuButton(ServerGroup, "Spawn Item", function()
    local itemName = MachoMenuGetInputbox(Item)
    local amount = tonumber(MachoMenuGetInputbox(AmountToGive))
    if not itemName or not amount or amount <= 0 then return end

    if isResourceRunning("ak47_drugmanager") then
        MachoInjectResource("ak47_drugmanager", string.format("TriggerServerEvent('ak47_drugmanager:pickedupitem', '%s', '%s', %d)", itemName, itemName, amount))
        return
    end

    if isResourceRunning("pug-fishing") then
        MachoInjectResource("pug-fishing", string.format("PugFishToggleItem(true, '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("pug-businesscreator") then
        MachoInjectResource("pug-businesscreator", string.format("BusinessToggleItem(true, '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("angelicxs-CivilianJobs") then
        MachoInjectResource("angelicxs-CivilianJobs", string.format("TriggerServerEvent('angelicxs-CivilianJobs:Server:GainItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("xmmx_letscookplus") then
        MachoInjectResource("xmmx_letscookplus", string.format([[TriggerServerEvent('xmmx_letscookplus:server:BuyItems', {
            totalCost = 0,
            cart = {
                {name = '%s', quantity = %d}
            }
        }, 'bank')]], itemName, amount))
        return
    end

    if isResourceRunning("codem-pausemenu") then
        MachoInjectResource("codem-pausemenu", string.format([[TriggerServerEvent('codem-pausemenu:ClaimBattlepassItem', {
            premium = false,
            amount = %d,
            requiredXP = 0,
            label = '%s',
            image = '%s.png',
            type = 'money',
            level = 1
        }, 1)]], amount, itemName, itemName))
        return
    end

    if isResourceRunning("boii-consumables") then
        MachoInjectResource("boii-consumables", string.format("TriggerServerEvent('boii-consumables:sv:AddItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("apex_galaxy") then
        MachoInjectResource("apex_galaxy", string.format("TriggerServerEvent('apex_galaxy:server:giveItem', '%s', '%d', '%d')", itemName, amount, 1))
        return
    end

MachoInjectResource('jim-bakery', [[
    risk_TriggerServerEvent = TriggerServerEvent

  risk_TriggerServerEvent("jim-bakery:server:toggleItem", true, itemName, amount))
]])
    if isResourceRunning("streetcode_PlugTalk") then
        MachoInjectResource("streetcode_PlugTalk", string.format("TriggerServerEvent('DrugBuy:drugshop', '%s', 0, %d)", itemName, amount))
        return
    end
MachoInjectResource('ak47_drugmanagerv2', [[
    TriggerServerEvent = TriggerServerEvent

  TriggerServerEvent("ak47_drugmanagerv2:shop:buy", true, "radio", 1)
]])

    if isResourceRunning("apex_pearls") then
        MachoInjectResource("apex_pearls", string.format("TriggerServerEvent('apex_pearls:server:giveItem', '%s', '%d', '%d')", itemName, amount, 1))
        return
    end

    if isResourceRunning("wasabi_mining") then
        MachoInjectResource("wasabi_mining", string.format([[TriggerServerEvent('wasabi_mining:mineRock', {difficulty = {"medium", "easy"}, item = '%s', label = "Emerald", price = {3000, 6000}}, 2)]], itemName))
        return
    end

    if isResourceRunning("jim-recycle") then
        MachoInjectResource("jim-recycle", string.format("TriggerServerEvent('jim-recycle:server:toggleItem', true, '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("boii-drugs") then
        MachoInjectResource("boii-drugs", string.format("TriggerServerEvent('boii-drugs:sv:AddItem', '%s', %d)", itemName, amount))
    end

    if isResourceRunning("ak47_idcard") then
        MachoInjectResource("ak47_idcard", string.format("TriggerServerEvent('ak47_idcard:giveid', '%s')", itemName))
        return
    end

    if isResourceRunning("esx_policejob") then
        MachoInjectResource("esx_policejob", string.format("TriggerServerEvent('esx_policejob:giveWeapon', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("esx_weashop") then
        MachoInjectResource("esx_weashop", string.format("TriggerServerEvent('esx_weashop:buyItem', '%s', %d, 'BlackWeashop')", itemName, amount))
        return
    end

    if isResourceRunning("pl_rustybrowns") then
        MachoInjectResource("pl_rustybrowns", string.format("TriggerServerEvent('pl_rustybrowns:servercraftitem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("mc9-weapondealer") then
        MachoInjectResource("mc9-weapondealer", string.format("TriggerServerEvent('mc9-weapondealer:server:giveItem', '%s')", itemName))
        return
    end

    if isResourceRunning("mc9-cyberbar") then
        MachoInjectResource("mc9-cyberbar", string.format("TriggerServerEvent('mc9-cyberbar:server:AddItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("drc_uwucafe") then
        MachoInjectResource("uwucafe", string.format("TriggerServerEvent('uwucafe:addItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("devcore_smokev2") then
        MachoInjectResource("devcore_smokev2", string.format("TriggerServerEvent('devcore_smokev2:server:AddItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("truckrobbery") then
        MachoInjectResource("truckrobbery", string.format("TriggerServerEvent('truckrobbery:addItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("qb-activities") then
        MachoInjectResource("qb-activities", string.format("TriggerServerEvent('qb-activities:pawnPayout', %d, '%s', %d)", amount, itemName, amount))
        return
    end

    if isResourceRunning("boii-whitewidow") then
        MachoInjectResource("boii-whitewidow", string.format("TriggerServerEvent('boii-whitewidow:server:AddItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("BJCore") then
        MachoInjectResource("BJCore", string.format("TriggerServerEvent('BJCore:Server:AddItem', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("Pug") then
        MachoInjectResource("Pug", string.format("TriggerServerEvent('Pug:server:GiveFish', '%s', %d)", itemName, amount))
        return
    end
    MachoInjectResource('esx', [[
    TriggerServerEvent = TriggerServerEvent

  TriggerServerEvent("esx:giveInventoryitem", true, itemName, amount))
 
]])
    if isResourceRunning("rpuk") then
        MachoInjectResource("rpuk", string.format("TriggerServerEvent('rpuk:failedItemUsage', '%s')", itemName))
        return
    end

    if isResourceRunning("rpuk_robberies") then
        MachoInjectResource("rpuk_robberies", string.format("TriggerServerEvent('rpuk_robberies:shops:unwrapCash', '%s', %s)", itemName, itemName))
        return
    end

    if isResourceRunning("fs_placeables") then
        MachoInjectResource("fs_placeables", string.format("TriggerServerEvent('fs_placeables:placeonground', '%s', %d)", itemName, amount))
        return
    end

    if isResourceRunning("mkbuss") then
        MachoInjectResource("mkbuss", string.format("TriggerServerEvent('mkbuss:giveReward', '%s', '%s', %d)", itemName, itemName, amount))
        return
    end

    if isResourceRunning("t1ger_minerjob") then
        MachoInjectResource("t1ger_minerjob", string.format("TriggerServerEvent('t1ger_minerjob:washingReward', '%s', %d)", itemName, amount))
        return
    end
end)

-- === SERVER TOOLS (EXPLOITS) — BUTTONS ONLY === --

MachoMenuButton(ServerToolsGroup, "PD JOB", function()
    TriggerEvent('esx:setJob', {name = "police", label = "LSPD", grade = 3, grade_name = "officer", grade_label = "Captain"})
    printerror("PD JOB SET")
end)

MachoMenuButton(ServerToolsGroup, "EMS JOB", function()
    TriggerEvent('esx:setJob', {name = "Ambulance", label = "EMS", grade = 3, grade_name = "officer", grade_label = "Captain"})
    printerror("EMS JOB SET")
end)

MachoMenuButton(ServerToolsGroup, "INVENTORY [E] STEALER", function()
    local function GetClosestPlayer()
        local closestPlayer = -1
        local closestDistance = -1
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, playerId in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(playerId)
            if targetPed ~= playerPed then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                if closestDistance == -1 or distance < closestDistance then
                    closestPlayer = playerId
                    closestDistance = distance
                end
            end
        end

        return closestPlayer, closestDistance
    end

    local function ForceHandsUpOnPlayer(ped)
        local dict = "missminuteman_1ig_2"
        local anim = "handsup_base"

        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end

        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
    end

    local function StopRobbing()
        if targetPlayer and DoesEntityExist(GetPlayerPed(targetPlayer)) then
            ClearPedTasks(GetPlayerPed(targetPlayer))
        end

        robbing = false
        targetPlayer = nil
    end

    -- Main thread for robbery interaction
    CreateThread(function()
        while true do
            Wait(0)

            if not robbing then
                local closestPlayer, distance = GetClosestPlayer()

                if closestPlayer ~= -1 and distance <= 2.0 then
                    if IsControlJustReleased(0, 38) then -- E key
                        robbing = true
                        targetPlayer = closestPlayer

                        -- Make target put hands up
                        ForceHandsUpOnPlayer(GetPlayerPed(targetPlayer))

                        -- Inject custom resource logic
                        MachoInjectResource('TriggerResource', [[
                            local function g()
                                local targetServerId = GetPlayerServerId(targetPlayer)
                                TriggerServerEvent("robbery:started", targetServerId)
                            end
                            g()
                        ]])

                        -- Open inventory
                        TriggerEvent('ox_inventory:openInventory', 'otherplayer', GetPlayerServerId(targetPlayer))
                    end
                end
            else
                DrawTextOnScreen("Press ~r~E~s~ to stop robbing")

                if IsControlJustReleased(0, 38) then -- E key
                    StopRobbing()
                end
            end
        end
    end)
end)

    MachoMenuButton(ServerToolsGroup, "Open Exploit Menu", function()
        TriggerServerEvent('inventory:server:OpenInventory', 'shop', 'Trader', {
            label = 'Trader',
            items = {
                [1] = {price = 0, info = {}, amount = 9999, name = 'weapon_knife', type = 'weapon', slot = 1},
                [2] = {price = 0, info = {}, amount = 9999, name = 'armor', type = 'item', slot = 2},
                [3] = {price = 0, info = {}, amount = 9999, name = 'pistol_ammo', type = 'item', slot = 3},
                [4] = {price = 0, info = {}, amount = 9999, name = 'WEAPON_GLOCK22', type = 'weapon', slot = 4},
                [5] = {price = 0, info = {}, amount = 9999, name = 'WEAPON_GLOCK18C', type = 'weapon', slot = 5},
                [6] = {price = 0, info = {}, amount = 9999, name = 'bandage', type = 'item', slot = 6},
            }
        })
    end)

-- Helper function to draw text on screen
function DrawTextOnScreen(text)
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(185, 185, 185, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.85)
end

-- === TRIGGER PAYLOADER (Left Group) === --
local eventPayloadInput = MachoMenuInputbox(ServerGroup, "Event Payload", '')
local eventTypeInput = MachoMenuInputbox(ServerGroup, "Event Type", "")
local resourceNameInput = MachoMenuInputbox(ServerGroup, "Resource Name", "")

MachoMenuButton(ServerGroup, "Execute Trigger", function()
    local payloadStr = MachoMenuGetInputbox(eventPayloadInput)
    local eventType = MachoMenuGetInputbox(eventTypeInput)
    local resource = MachoMenuGetInputbox(resourceNameInput)

    local ok, payload = pcall(function() return json.decode(payloadStr) end)

    if not ok then
        printerror("Invalid JSON payload")
        return
    end

    if eventType == "" or resource == "" then
        printerror("Event Type and Resource cannot be empty")
        return
    end

        MachoMenuButton(TradeSection, "Open Exploit Menu", function()
        TriggerServerEvent('inventory:server:OpenInventory', 'shop', 'Trader', {
            label = 'Trader',
            items = {
                [1] = {price = 0, info = {}, amount = 9999, name = 'weapon_knife', type = 'weapon', slot = 1},
                [2] = {price = 0, info = {}, amount = 9999, name = 'armor', type = 'item', slot = 2},
                [3] = {price = 0, info = {}, amount = 9999, name = 'pistol_ammo', type = 'item', slot = 3},
                [4] = {price = 0, info = {}, amount = 9999, name = 'WEAPON_GLOCK22', type = 'weapon', slot = 4},
                [5] = {price = 0, info = {}, amount = 9999, name = 'WEAPON_GLOCK18C', type = 'weapon', slot = 5},
                [6] = {price = 0, info = {}, amount = 9999, name = 'bandage', type = 'item', slot = 6},
            }
        })
    end)
    -- Execute your event trigger here:
    -- If it's a client event:
    -- TriggerEvent(eventType, payload)

    -- If it's a server event:
    -- TriggerServerEvent(eventType, payload)

    -- Example:
    TriggerServerEvent(eventType, payload)

    printsuccess("Triggered event '" .. eventType .. "' on resource '" .. resource .. "'")
end)

-- === TRIGGER EXECUTOR (Right Group) === --

local triggerNameInput = MachoMenuInputbox(ServerToolsGroup, "Trigger Name", "")

MachoMenuButton(ServerToolsGroup, "Execute Trigger", function()
    local triggerName = MachoMenuGetInputbox(triggerNameInput)

    if triggerName == "" then
        printerror("Please enter a trigger name")
        return
    end

    -- Call your existing trigger function here
    -- Replace this with your actual trigger call:
    ExistingTriggerFunction(triggerName)

    printsuccess("Executed trigger: " .. triggerName)
end)




-- === WEAPON MODS TAB ELEMENTS ===
local WeaponModsGroup = MachoMenuGroup(WeaponTab, "Weapon Mods", 124, 10, 350, 1000)
local WeaponMiscGroup = MachoMenuGroup(WeaponTab, "Misc Mods", 350, 10, 700, 1000)

-- === MOD TOGGLES ===
MachoMenuCheckbox(WeaponModsGroup, "No Reload", function()
    SetPedInfiniteAmmoClip(PlayerPedId(), true)
    printsuccess("No Reload Enabled")
end, function()
    SetPedInfiniteAmmoClip(PlayerPedId(), false)
    printerror("No Reload Disabled")
end)

MachoMenuCheckbox(WeaponModsGroup, "Infinite Ammo", function()
    SetPedInfiniteAmmo(PlayerPedId(), true)
    printsuccess("Infinite Ammo Enabled")
end, function()
    SetPedInfiniteAmmo(PlayerPedId(), false)
    printerror("Infinite Ammo Disabled")
end)

MachoMenuCheckbox(WeaponModsGroup, "Explosive Ammo", function()
    CreateThread(function()
        while true do
            Wait(0)
            if not explosiveAmmoActive then break end
            SetExplosiveAmmoThisFrame(PlayerPedId())
        end
    end)
    explosiveAmmoActive = true
    printsuccess("Explosive Ammo Enabled")
end, function()
    explosiveAmmoActive = false
    printerror("Explosive Ammo Disabled")
end)


-- === DAMAGE MULTIPLIER SLIDER ===
MachoMenuSlider(WeaponMiscGroup, "Damage Multiplier", 10, 1, 100, "%", 0, function(value)
    SetPlayerWeaponDamageModifier(PlayerId(), value / 10.0)
    printinfo("Damage Multiplier set to " .. value .. "%")
end)

-- === WEAPON ATTACHMENTS ===
MachoMenuButton(WeaponMiscGroup, "Add Suppressor", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    GiveWeaponComponentToPed(PlayerPedId(), weapon, 'COMPONENT_AT_PI_SUPP')
    printsuccess("Suppressor added")
end)

MachoMenuButton(WeaponMiscGroup, "Remove Suppressor", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    RemoveWeaponComponentFromPed(PlayerPedId(), weapon, 'COMPONENT_AT_PI_SUPP')
    printsuccess("Suppressor removed")
end)

MachoMenuButton(WeaponMiscGroup, "Add Scope", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    GiveWeaponComponentToPed(PlayerPedId(), weapon, 'COMPONENT_AT_SCOPE_MACRO')
    printsuccess("Scope added")
end)

MachoMenuButton(WeaponMiscGroup, "Remove Scope", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    RemoveWeaponComponentFromPed(PlayerPedId(), weapon, 'COMPONENT_AT_SCOPE_MACRO')
    printsuccess("Scope removed")
end)

MachoMenuButton(WeaponMiscGroup, "Add Magazine", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    GiveWeaponComponentToPed(PlayerPedId(), weapon, 'COMPONENT_PISTOL_CLIP_02')
    printsuccess("Extended Magazine added")
end)

MachoMenuButton(WeaponMiscGroup, "Remove Magazine", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    RemoveWeaponComponentFromPed(PlayerPedId(), weapon, 'COMPONENT_PISTOL_CLIP_02')
    printsuccess("Extended Magazine removed")
end)

MachoMenuButton(WeaponMiscGroup, "Tint Weapon", function()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    SetPedWeaponTintIndex(PlayerPedId(), weapon, 5)
    printsuccess("Weapon tinted gold")
end)



-- Left Side: Vehicle Mods + Plate & Spawning
local VehicleModsGroup = MachoMenuGroup(VehicleTab, "Vehicle Mods", 124, 10, 380, 250)

MachoMenuButton(VehicleModsGroup, "Specific Vehicle Spawning", function()
    -- Add your spawn logic here
end)


MachoMenuButton(VehicleModsGroup, "Vehicle Godmode", function()
    -- Toggle godmode
end)

MachoMenuButton(VehicleModsGroup, "Vehicle Invisibility", function()
    -- Toggle invisibility
end)

MachoMenuButton(VehicleModsGroup, "Freeze Vehicle", function()
    -- Freeze logic
end)

local PlateGroup = MachoMenuGroup(VehicleTab, "Plate & Spawning", 124, 230, 370, 1000)

local plateInput = MachoMenuInputbox(PlateGroup, "License Plate", "LICENSE")
MachoMenuButton(PlateGroup, "Set License Plate", function()
    local plate = MachoMenuGetInputbox(plateInput)
    SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), plate)
    printsuccess("Plate set to " .. plate)
end)

local modelInput = MachoMenuInputbox(PlateGroup, "Model Name", "ADDER")
MachoMenuButton(PlateGroup, "Spawn Vehicle", function()
    local model = MachoMenuGetInputbox(modelInput)
    TriggerEvent("kryptic:client:spawnveh", model)
end)

-- Right Side: Misc
local VehicleMiscGroup = MachoMenuGroup(VehicleTab, "Misc", 370, 10, 700, 1000)

MachoMenuButton(VehicleMiscGroup, "Repair Vehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleFixed(veh)
    printsuccess("Vehicle repaired")
end)

MachoMenuButton(VehicleMiscGroup, "Stealth Repair Vehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleFixed(veh)
    SetVehicleDirtLevel(veh, 0.0)
end)

MachoMenuButton(VehicleMiscGroup, "Flip Vehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local coords = GetEntityCoords(veh)
    SetEntityCoords(veh, coords.x, coords.y, coords.z + 2.0, true, true, true, false)
    SetEntityRotation(veh, 0, 0, GetEntityHeading(veh), 2, true)
end)

MachoMenuButton(VehicleMiscGroup, "Clean Vehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleDirtLevel(veh, 0.0)
    printsuccess("Vehicle cleaned")
end)

MachoMenuButton(VehicleMiscGroup, "Delete Vehicle", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteEntity(vehicle)
    end
    printSuccess("Successfully executed: /dv")
end, false)

MachoMenuButton(VehicleMiscGroup, "Toggle Vehicle Engine", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local isRunning = GetIsVehicleEngineRunning(veh)
    SetVehicleEngineOn(veh, not isRunning, false, true)
    printinfo("Toggled engine state")
end)

MachoMenuButton(VehicleMiscGroup, "Max Vehicle Upgrades", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleModKit(veh, 0)
    for i = 0, 49 do
        local modCount = GetNumVehicleMods(veh, i)
        if modCount > 0 then
            SetVehicleMod(veh, i, modCount - 1, false)
        end
    end
    ToggleVehicleMod(veh, 18, true) -- Turbo
    SetVehicleWindowTint(veh, 1)
    printsuccess("Max upgrades applied")
end)

MachoMenuButton(VehicleMiscGroup, "Lock/Unlock Vehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local locked = GetVehicleDoorLockStatus(veh)
    if locked == 1 then
        SetVehicleDoorsLocked(veh, 2)
        printinfo("Vehicle locked")
    else
        SetVehicleDoorsLocked(veh, 1)
        printinfo("Vehicle unlocked")
    end
end)

MachoMenuButton(VehicleMiscGroup, "Unlock Closest Vehicle", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local radius = 10.0
    local closestVeh = GetClosestVehicle(pos.x, pos.y, pos.z, radius, 0, 70)
    if closestVeh then
        SetVehicleDoorsLocked(closestVeh, 1)
        printsuccess("Closest vehicle unlocked")
    else
        printerror("No vehicle found nearby")
    end
end)

local EmoteGroup = MachoMenuGroup(EmotesTab, "Emotes", 124, 10, 350, 1000)
local EmoteGroup = MachoMenuGroup(EmotesTab, "FORCE EMOTES", 400, 2, 700, 1000)
local EmoteList = { "wave", "salute", "dance", "sit" }

MachoMenuDropDown(EmoteGroup, "Choose Emote", function(index)
    TriggerEvent("kryptic:client:playemote", EmoteList[index])
end, table.unpack(EmoteList))

MachoMenuButton(EmoteGroup, "Stop Emote", function()
    TriggerEvent("kryptic:client:stopemote")
end)

-- Utility: Find the closest player to the local player
function GetClosestPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = -1, math.huge

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance < closestDistance then
                closestPlayer, closestDistance = playerId, distance
            end
        end
    end

    return closestPlayer, closestDistance
end

-- UI Button: Trigger emote if player is nearby
MachoMenuButton(EmoteGroup, "BLOWJOB", function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    print("Closest Player ID:", closestPlayer)
    print("Closest Distance:", closestDistance)

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetPlayerId = GetPlayerServerId(closestPlayer)
        print("Triggering event with Player ID:", targetPlayerId)
        TriggerServerEvent('ServerValidEmote', targetPlayerId, 'giveblowjob', 'receiveblowjob')
    else
        print("No nearby player found.")
    end
end)
MachoMenuButton(EmoteGroup, "Fuck the One Nearby", function()
    if isAnimating then
        MachoInjectResource('monitor', [[
            local playerPed = PlayerPedId()
            ClearPedTasks(playerPed)
            DetachEntity(playerPed, true, true)
            TriggerEvent('chat:addMessage', { args = { '^2ERP Sistemi:', 'Animation stopped!' } })
        ]])
        MachoMenuNotification("ERP Sistemi", "Aanimation has been stopped!")
        isAnimating = false
        return
    end
    
    MachoInjectResource('monitor', [[
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local peds = {}
        local pedHandle, ped = FindFirstPed()
        local success
        
        repeat
            if DoesEntityExist(ped) and ped ~= playerPed then
                local pedCoords = GetEntityCoords(ped)
                if Vdist(playerCoords, pedCoords) < 10.0 then
                    table.insert(peds, ped)
                end
            end
            success, ped = FindNextPed(pedHandle)
        until not success
        EndFindPed(pedHandle)
        
        local closestPed = nil
        local closestDistance = 3.0
        
        for _, ped in pairs(peds) do
            local pedCoords = GetEntityCoords(ped)
            local distance = Vdist(playerCoords, pedCoords)
            if distance < closestDistance and ped ~= playerPed then
                closestPed = ped
                closestDistance = distance
            end
        end
        
        if closestPed then
            local animDict = "rcmpaparazzo_2"
            local animName = "shag_loop_a"
            
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(0)
            end
            
            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            AttachEntityToEntity(playerPed, closestPed, 11816, 0.0, -0.6, 0.0, 0.5, 0.5, 0.0, true, true, true, true, 0, true)
            
            TriggerEvent('chat:addMessage', { args = { '^2ERP Sistemi:', 'Yakındaki ped için animasyon uygulandı!' } })
        else
            TriggerEvent('chat:addMessage', { args = { '^1ERP Sistemi:', 'Yakında uygun ped bulunamadı!' } })
        end
    ]])
    
    MachoMenuNotification("ERP System", "Animation applied to nearby pad!")
    isAnimating = true
end)

MachoMenuButton(EmoteGroup, "Fuck the Nearby Exhaust", function()
    if isAnimating then
        MachoInjectResource('monitor', [[
            local playerPed = PlayerPedId()
            ClearPedTasks(playerPed)
            DetachEntity(playerPed, true, true)
            local originalCoords = GetEntityCoords(playerPed)
            SetEntityCoords(playerPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, true)
            TriggerEvent('chat:addMessage', { args = { '^2ERP SYSTEM:', 'The animation is stopped and the previous position is restored!' } })
        ]])
        MachoMenuNotification("ERP SYSTEM", "The animation is stopped and the previous position is restored!")
        isAnimating = false
        return
    end
    
    MachoInjectResource('monitor', [[
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local maxAttachDistance = 10.0
        local vehicles = {}
        local handle, vehicle = FindFirstVehicle()
        local success
        
        repeat
            success, vehicle = FindNextVehicle(handle)
            if success then
                table.insert(vehicles, vehicle)
            end
        until not success
        EndFindVehicle(handle)
        
        local closestVehicle = nil
        local closestDistance = maxAttachDistance
        
        for _, vehicle in ipairs(vehicles) do
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = Vdist(playerCoords, vehicleCoords)
            if distance < closestDistance then
                closestVehicle = vehicle
                closestDistance = distance
            end
        end
        
        if closestVehicle then
            local vehicleCoords = GetEntityCoords(closestVehicle)
            local heading = GetEntityHeading(closestVehicle)
            local radians = math.rad(heading)
            local rearOffset = 5.0
            local sideOffset = 2.0
            local xRearOffset = rearOffset * math.cos(radians)
            local yRearOffset = rearOffset * math.sin(radians)
            local xSideOffset = sideOffset * math.sin(radians)
            local ySideOffset = -sideOffset * math.cos(radians)
            local offsetCoords = vehicleCoords + vector3(xRearOffset + xSideOffset, yRearOffset + ySideOffset, 0.0)
            
            SetEntityCoords(playerPed, offsetCoords.x, offsetCoords.y, offsetCoords.z, false, false, false, true)
            SetEntityHeading(playerPed, heading)
            
            local animDict = "rcmpaparazzo_2"
            local animName = "shag_loop_a"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(100)
            end
            TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            
            AttachEntityToEntity(playerPed, closestVehicle, 0, 0.0, -3.0, 0.6, 0.0, 0.0, heading, true, true, false, true, 7, true)
            
            TriggerEvent('chat:addMessage', { args = { '^2ERP SYSTEM:', 'Animated nearby vehicle exhaust!' } })
        else
            TriggerEvent('chat:addMessage', { args = { '^1ERP SYSTEM:', 'Animated nearby vehicle exhaust!' } })
        end
    ]])
    
    MachoMenuNotification("ERP System", "Animated nearby vehicle exhaust!")
    isAnimating = true
end)

-- Settings Groups (attached to ApiTab)
local SettingsGroup1 = MachoMenuGroup(ApiTab, "Bypasses", 124, 2, 400, 1000)
local SettingsGroup2 = MachoMenuGroup(ApiTab, "Misc", 400, 2, 700, 1000)

-- Optional: background color
if MachoMenuSetBackgroundColor then
    MachoMenuSetBackgroundColor(SettingsGroup1, 40, 40, 40, 180)
    MachoMenuSetBackgroundColor(SettingsGroup2, 40, 40, 40, 180)
end

-- === TEST BUTTONS (replacing toggles) ===
local testButtons = {
    "REAPER BYPASS V4", "WAVE SHEID BYPASS", "FIVEGUARD BYPASS",
}

for _, label in ipairs(testButtons) do
    MachoMenuButton(SettingsGroup1, label, function()
        print(label .. " Pressed")
    end)
end

-- === TEST SLIDERS ===


-- === MORE TEST BUTTONS ===
MachoMenuButton(SettingsGroup2, "Quit Game", function()
    ExecuteCommand("quit")
end)

MachoMenuCheckbox(SettingsGroup2, "Rainbow Menu",
    function()
        _G.rainbowUI = true
        _G.rainbowSpeed = 0.01
        Citizen.CreateThread(function()
            local rainbowOffset = 0
            while _G.rainbowUI do
                Citizen.Wait(10)
                rainbowOffset = rainbowOffset + _G.rainbowSpeed
                local red = math.floor(127 + 127 * math.sin(rainbowOffset))
                local green = math.floor(127 + 127 * math.sin(rainbowOffset + 2))
                local blue = math.floor(127 + 127 * math.sin(rainbowOffset + 4))
                MachoMenuSetAccent(MenuWindow, red, green, blue)
            end
        end)
    end,
    function()
        _G.rainbowUI = false
        MachoMenuSetAccent(MenuWindow, 255, 255, 255)
    end
)

MachoMenuButton(SettingsGroup2, "Close Captcha Menu", function()
    MachoMenuDestroy(MenuWindow)
end)

MachoMenuButton(SettingsGroup2, "Anti Cheat Checker", function()
    MachoInjectResource("any", [[
    for i = 0, GetNumResources() - 1 do
        local resource_name = GetResourceByFindIndex(i)

        if resource_name and GetResourceState(resource_name) == "started" then
            local client_script_count = GetNumResourceMetadata(resource_name, "client_script")
            local server_script_count = GetNumResourceMetadata(resource_name, "server_script")

            if resource_name == "WaveShield" or resource_name == "FiniAc" or
            resource_name == "qb-anticheat" or resource_name == "venus_anticheat" or resource_name == "anticheese" or resource_name == "fiveguard" or
            resource_name == "FIREAC" or resource_name == "FuriousAntiCheat" or resource_name == "fg" or 
            resource_name == "phoenix" or resource_name == "TitanAC" or resource_name == "VersusAC" or resource_name == "VersusAC-OCR" or 
            resource_name == "waveshield" or resource_name == "anticheese-anticheat-master" or resource_name == "anticheese-anticheat" or
            resource_name == "wx-anticheat" or resource_name == "AntiCheese" or resource_name == "AntiCheese-master" or resource_name == "somis_anticheat" or resource_name == "somis-anticheat" or 
            resource_name == "ClownGuard" or resource_name == "oltest" or resource_name == "ChocoHax" or resource_name == "ESXAC" or
            resource_name == "TigoAC" or resource_name == "VenusAC" then
                print("Detected Anticheat: [" .. resource_name .. "]")
                print('Resource: ^7[^1' .. resource_name .. '^7]')
                goto continue
            end

            if GetResourceMetadata(resource_name, "ac", 0) == "fg" then
                print("Detected Anticheat: [Fiveguard]")
                print('Resource: ^7[^1' .. resource_name .. '^7]')
                goto continue
            end

            if resource_name == "vRP" or resource_name == "vrp" then
                rp = true
            end

            if client_script_count == 4 and resource_name ~= seconderes then
                local valid_client_scripts = {
                    ["lib/Tunnel.lua"] = true,
                    ["lib/Proxy.lua"] = true,
                    ["client.lua"] = true,
                    ["69.lua"] = true
                }
                if valid_client_scripts[GetResourceMetadata(resource_name, "client_script", 0)] and
                   valid_client_scripts[GetResourceMetadata(resource_name, "client_script", 1)] and
                   valid_client_scripts[GetResourceMetadata(resource_name, "client_script", 2)] and
                   valid_client_scripts[GetResourceMetadata(resource_name, "client_script", 3)] then
                    firstres = resource_name
                end
            end

            if server_script_count == 2 and resource_name ~= firstres then
                if GetResourceMetadata(resource_name, "server_script", 0) == "@vrp/lib/utils.lua" and
                   GetResourceMetadata(resource_name, "server_script", 1) == "server.lua" and
                   GetResourceMetadata(resource_name, "client_script", 0) == "lib/Tunnel.lua" and
                   GetResourceMetadata(resource_name, "client_script", 1) == "lib/Proxy.lua" and
                   GetResourceMetadata(resource_name, "client_script", 2) == 'client.lua' then
                    seconderes = resource_name
                end
            end
        end
        ::continue::
    end
]])
end)