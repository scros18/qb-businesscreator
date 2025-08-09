-- QB-Core Dynamic Business Creation System with Website Builder
-- Client Side Script (qb-businesscreator/client/main.lua)

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

-- Local Variables
local currentBusiness = nil
local inBusinessZone = false
local websiteBuilderOpen = false
local computerProp = nil
local businessBlips = {}

-- Business Creation Menu
RegisterNetEvent('qb-business:client:openCreationMenu', function()
    local menu = {
        {
            header = "Business Creation Center",
            isMenuHeader = true
        }
    }
    
    for typeId, businessType in pairs(Config.BusinessTypes) do
        if businessType.legal then
            table.insert(menu, {
                header = businessType.name,
                txt = "Starting Price: $" .. businessType.basePrice .. " | Max Employees: " .. businessType.maxEmployees,
                params = {
                    event = "qb-business:client:selectBusinessType",
                    args = {
                        type = typeId,
                        data = businessType
                    }
                }
            })
        end
    end
    
    -- Add secret illegal business option if player has certain item or reputation
    if PlayerData.items and HasItem("vpn_device") then
        table.insert(menu, {
            header = "🔒 Special Ventures",
            txt = "Requires VPN Device | Higher Risk, Higher Reward",
            params = {
                event = "qb-business:client:showIllegalBusinesses"
            }
        })
    end
    
    exports['qb-menu']:openMenu(menu)
end)

-- Website Builder Interface
RegisterNetEvent('qb-business:client:openWebsiteBuilder', function(data)
    if websiteBuilderOpen then return end
    
    websiteBuilderOpen = true
    SetNuiFocus(true, true)
    
    -- Create computer prop and animation
    StartComputerAnimation()
    
    SendNUIMessage({
        action = "openWebsiteBuilder",
        businessData = data.businessData,
        templates = data.templates,
        currentWebsite = data.currentWebsite
    })
end)

-- NUI Callbacks for Website Builder
RegisterNUICallback('selectTemplate', function(data, cb)
    SendNUIMessage({
        action = "loadTemplate",
        template = data.template
    })
    cb('ok')
end)

RegisterNUICallback('updateWebsiteElement', function(data, cb)
    -- Real-time preview updates
    SendNUIMessage({
        action = "updatePreview",
        element = data.element,
        value = data.value
    })
    cb('ok')
end)

RegisterNUICallback('uploadImage', function(data, cb)
    -- Handle image upload (could connect to a real image hosting service)
    TriggerServerEvent('qb-business:server:uploadImage', data)
    cb('ok')
end)

RegisterNUICallback('saveWebsite', function(data, cb)
    TriggerServerEvent('qb-business:server:saveWebsite', data)
    cb('ok')
end)

RegisterNUICallback('publishWebsite', function(data, cb)
    data.isLive = true
    TriggerServerEvent('qb-business:server:saveWebsite', data)
    
    QBCore.Functions.Notify('Website is now live at: ' .. data.domain, 'success', 7000)
    cb('ok')
end)

RegisterNUICallback('closeWebsiteBuilder', function(data, cb)
    websiteBuilderOpen = false
    SetNuiFocus(false, false)
    StopComputerAnimation()
    cb('ok')
end)

-- In-Game Browser for Viewing Websites
RegisterCommand('business-web', function(args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /business-web [domain]', 'error')
        return
    end
    
    OpenBusinessWebsite(args[1])
end)

function OpenBusinessWebsite(domain)
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "openBrowser",
        url = domain
    })
end

-- Computer Interaction for Website Builder
CreateThread(function()
    -- Create computer zones at specific locations
    local computerLocations = {
        {x = -1081.85, y = -248.31, z = 37.76}, -- Life Invader Office
        {x = -1371.42, y = -457.89, z = 34.48}, -- Downtown Office
        {x = 1272.37, y = -1711.74, z = 54.77}, -- Lester's House
        -- Add more locations
    }
    
    for _, loc in ipairs(computerLocations) do
        exports['qb-target']:AddBoxZone("business_computer_" .. _, 
            vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
            name = "business_computer_" .. _,
            heading = 0,
            debugPoly = false,
            minZ = loc.z - 1,
            maxZ = loc.z + 1
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-business:client:useComputer",
                    icon = "fas fa-laptop",
                    label = "Use Computer"
                }
            },
            distance = 2.0
        })
    end
end)

RegisterNetEvent('qb-business:client:useComputer', function()
    local menu = {
        {
            header = "Business Computer",
            isMenuHeader = true
        },
        {
            header = "Website Builder",
            txt = "Create or edit your business website",
            params = {
                event = "qb-business:client:selectBusinessForWebsite"
            }
        },
        {
            header = "View Analytics",
            txt = "Check your business performance",
            params = {
                event = "qb-business:client:viewAnalytics"
            }
        },
        {
            header = "Online Orders",
            txt = "Manage customer orders",
            params = {
                event = "qb-business:client:viewOrders"
            }
        },
        {
            header = "Browse Business Network",
            txt = "View other business websites",
            params = {
                event = "qb-business:client:browseBusinesses"
            }
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end)

-- Business Management Tablet
RegisterNetEvent('qb-business:client:openManagementTablet', function()
    if not currentBusiness then
        QBCore.Functions.Notify('You need to be at your business', 'error')
        return
    end
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "openManagementTablet",
        business = currentBusiness
    })
end)

-- Employee Management
RegisterNetEvent('qb-business:client:manageEmployees', function()
    local menu = {
        {
            header = "Employee Management",
            isMenuHeader = true
        },
        {
            header = "Hire Employee",
            txt = "Recruit new staff",
            params = {
                event = "qb-business:client:hireEmployee"
            }
        },
        {
            header = "View Employees",
            txt = "See current staff and roles",
            params = {
                event = "qb-business:client:viewEmployees"
            }
        },
        {
            header = "Payroll Settings",
            txt = "Manage salaries and bonuses",
            params = {
                event = "qb-business:client:payrollSettings"
            }
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end)

-- Product Management with Live Website Updates
RegisterNetEvent('qb-business:client:manageProducts', function()
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "openProductManager",
        business = currentBusiness
    })
end)

RegisterNUICallback('addProduct', function(data, cb)
    TriggerServerEvent('qb-business:server:addProduct', {
        businessId = currentBusiness.id,
        product = data.product
    })
    
    QBCore.Functions.Notify('Product added to website!', 'success')
    cb('ok')
end)

RegisterNUICallback('updateProduct', function(data, cb)
    TriggerServerEvent('qb-business:server:updateProduct', {
        businessId = currentBusiness.id,
        productId = data.productId,
        updates = data.updates
    })
    cb('ok')
end)

-- Customer Interaction System
CreateThread(function()
    while true do
        Wait(0)
        
        if currentBusiness and inBusinessZone then
            -- Check for nearby players (potential customers)
            local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 10.0)
            
            for _, player in ipairs(players) do
                if player ~= PlayerId() then
                    DrawText3D(GetEntityCoords(GetPlayerPed(player)), "Press [E] to view menu")
                    
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('qb-business:server:requestMenu', currentBusiness.id, GetPlayerServerId(player))
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)

-- Business Zone Detection
CreateThread(function()
    while true do
        Wait(1000)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for businessId, business in pairs(GetNearbyBusinesses()) do
            local distance = #(playerCoords - business.location)
            
            if distance < 50.0 then
                if not inBusinessZone then
                    inBusinessZone = true
                    currentBusiness = business
                    TriggerEvent('qb-business:client:enteredBusiness', business)
                end
            else
                if inBusinessZone and currentBusiness.id == businessId then
                    inBusinessZone = false
                    currentBusiness = nil
                    TriggerEvent('qb-business:client:leftBusiness')
                end
            end
        end
    end
end)

-- Animation Functions
function StartComputerAnimation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Create laptop prop
    RequestModel('prop_laptop_01a')
    while not HasModelLoaded('prop_laptop_01a') do
        Wait(0)
    end
    
    computerProp = CreateObject(GetHashKey('prop_laptop_01a'), playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    AttachEntityToEntity(computerProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.12, 0.10, -0.05, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Play typing animation
    RequestAnimDict("anim@heists@prison_heiststation@cop_reactions")
    while not HasAnimDictLoaded("anim@heists@prison_heiststation@cop_reactions") do
        Wait(0)
    end
    
    TaskPlayAnim(playerPed, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
end

function StopComputerAnimation()
    local playerPed = PlayerPedId()
    
    StopAnimTask(playerPed, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 1.0)
    
    if computerProp then
        DeleteObject(computerProp)
        computerProp = nil
    end
end

-- Helper Functions
function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function HasItem(item)
    for _, v in pairs(PlayerData.items) do
        if v.name == item then
            return true
        end
    end
    return false
end

function GetNearbyBusinesses()
    -- This would typically fetch from server
    return {}
end

-- Business Blips
RegisterNetEvent('qb-business:client:updateBlips', function(businesses)
    -- Clear existing blips
    for _, blip in ipairs(businessBlips) do
        RemoveBlip(blip)
    end
    businessBlips = {}
    
    -- Create new blips
    for _, business in ipairs(businesses) do
        if business.isOpen then
            local blip = AddBlipForCoord(business.location.x, business.location.y, business.location.z)
            SetBlipSprite(blip, GetBusinessBlipSprite(business.type))
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, GetBusinessBlipColor(business.type))
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(business.name)
            EndTextCommandSetBlipName(blip)
            
            table.insert(businessBlips, blip)
        end
    end
end)

function GetBusinessBlipSprite(businessType)
    local sprites = {
        restaurant = 93,
        nightclub = 121,
        mechanic = 446,
        dealership = 523,
        carwash = 100
    }
    return sprites[businessType] or 374
end

function GetBusinessBlipColor(businessType)
    local colors = {
        restaurant = 31,
        nightclub = 48,
        mechanic = 67,
        dealership = 3,
        carwash = 38
    }
    return colors[businessType] or 0
end

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('qb-business:server:requestBusinessData')
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('qb-business:client:refreshBusinessData', function(business)
    currentBusiness = business
end)

-- Exports
exports('GetCurrentBusiness', function()
    return currentBusiness
end)

exports('IsInBusinessZone', function()
    return inBusinessZone
end)