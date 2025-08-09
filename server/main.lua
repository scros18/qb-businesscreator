-- QB-Core Dynamic Business Creation System with Website Builder
-- Server Side Script (qb-businesscreator/server/main.lua)

local QBCore = exports['qb-core']:GetCoreObject()

-- Business Data Storage
local Businesses = {}
local BusinessWebsites = {}
local BusinessEmployees = {}
local BusinessInventories = {}
local BusinessOrders = {}

-- Website Templates Configuration
Config = Config or {}
Config.WebsiteTemplates = {
    modern = {
        name = "Modern Business",
        price = 5000,
        customizable = {"colors", "logo", "banner", "products", "about", "contact"},
        baseHTML = "templates/modern.html"
    },
    classic = {
        name = "Classic Professional",
        price = 3000,
        customizable = {"colors", "logo", "banner", "services", "team", "contact"},
        baseHTML = "templates/classic.html"
    },
    minimal = {
        name = "Minimalist",
        price = 2000,
        customizable = {"colors", "logo", "products", "contact"},
        baseHTML = "templates/minimal.html"
    },
    restaurant = {
        name = "Restaurant Special",
        price = 4000,
        customizable = {"colors", "logo", "menu", "reservations", "gallery", "contact"},
        baseHTML = "templates/restaurant.html"
    },
    nightlife = {
        name = "Nightlife & Entertainment",
        price = 6000,
        customizable = {"colors", "logo", "events", "vip", "gallery", "booking"},
        baseHTML = "templates/nightlife.html"
    },
    underground = {
        name = "Dark Web",
        price = 10000,
        customizable = {"colors", "logo", "products", "encrypted_chat"},
        baseHTML = "templates/underground.html",
        requiresVPN = true
    }
}

-- Business Types with Website Features
Config.BusinessTypes = {
    restaurant = {
        name = "Restaurant",
        legal = true,
        basePrice = 150000,
        maxEmployees = 8,
        features = {
            website = true,
            onlineOrders = true,
            delivery = true,
            reservations = true
        },
        products = {
            {id = "burger", name = "Burger", price = 15, craftable = true},
            {id = "pizza", name = "Pizza", price = 20, craftable = true},
            {id = "drinks", name = "Drinks", price = 5, craftable = false},
            {id = "dessert", name = "Dessert", price = 10, craftable = true}
        }
    },
    nightclub = {
        name = "Nightclub",
        legal = true,
        basePrice = 500000,
        maxEmployees = 12,
        features = {
            website = true,
            ticketSales = true,
            vipBooking = true,
            eventCalendar = true
        }
    },
    dealership = {
        name = "Vehicle Dealership",
        legal = true,
        basePrice = 1000000,
        maxEmployees = 10,
        features = {
            website = true,
            vehicleShowcase = true,
            testDriveBooking = true,
            financing = true
        }
    },
    -- Illegal Businesses
    drugoperation = {
        name = "Import/Export",
        legal = false,
        basePrice = 750000,
        maxEmployees = 6,
        features = {
            website = true, -- Dark web presence
            encryptedOrders = true,
            cryptoPayments = true
        },
        requiresVPN = true
    },
    weaponsdealer = {
        name = "Security Consulting",
        legal = false,
        basePrice = 1500000,
        maxEmployees = 4,
        features = {
            website = true,
            encryptedCatalog = true,
            deadDrops = true
        },
        requiresVPN = true
    }
}

-- Create Business
RegisterNetEvent('qb-business:server:createBusiness', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local businessType = Config.BusinessTypes[data.type]
    if not businessType then 
        TriggerClientEvent('QBCore:Notify', src, 'Invalid business type', 'error')
        return 
    end
    
    -- Check if player has enough money
    if Player.PlayerData.money.bank < businessType.basePrice then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        return
    end
    
    -- Generate unique business ID
    local businessId = GenerateBusinessId()
    
    -- Create business
    Businesses[businessId] = {
        id = businessId,
        owner = Player.PlayerData.citizenid,
        name = data.name,
        type = data.type,
        location = data.location,
        created = os.time(),
        employees = {},
        inventory = {},
        money = 0,
        reputation = 50,
        customers = 0,
        isOpen = false,
        customization = {
            interior = data.interior or "default",
            signage = data.signage or "default"
        },
        features = businessType.features,
        website = nil
    }
    
    -- Deduct money
    Player.Functions.RemoveMoney('bank', businessType.basePrice)
    
    -- Save to database
    MySQL.Async.insert('INSERT INTO player_businesses (business_id, owner, name, type, data) VALUES (?, ?, ?, ?, ?)', {
        businessId,
        Player.PlayerData.citizenid,
        data.name,
        data.type,
        json.encode(Businesses[businessId])
    })
    
    -- Create default website
    if businessType.features.website then
        CreateDefaultWebsite(businessId)
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Business created successfully!', 'success')
    TriggerClientEvent('qb-business:client:refreshBusinessData', src, Businesses[businessId])
end)

-- Website Builder Functions
RegisterNetEvent('qb-business:server:openWebsiteBuilder', function(businessId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Businesses[businessId] or Businesses[businessId].owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t own this business', 'error')
        return
    end
    
    local websiteData = BusinessWebsites[businessId] or GetDefaultWebsiteData(businessId)
    
    TriggerClientEvent('qb-business:client:openWebsiteBuilder', src, {
        businessId = businessId,
        templates = Config.WebsiteTemplates,
        currentWebsite = websiteData,
        businessData = Businesses[businessId]
    })
end)

-- Save Website Design
RegisterNetEvent('qb-business:server:saveWebsite', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Businesses[data.businessId] or Businesses[data.businessId].owner ~= Player.PlayerData.citizenid then
        return
    end
    
    BusinessWebsites[data.businessId] = {
        template = data.template,
        customization = data.customization,
        content = data.content,
        products = data.products,
        seo = {
            title = data.seo.title or Businesses[data.businessId].name,
            description = data.seo.description,
            keywords = data.seo.keywords
        },
        analytics = {
            visits = 0,
            orders = 0,
            revenue = 0
        },
        isLive = data.isLive or false,
        domain = GenerateDomain(Businesses[data.businessId].name),
        lastUpdated = os.time()
    }
    
    -- Save to database
    MySQL.Async.execute('UPDATE player_businesses SET website_data = ? WHERE business_id = ?', {
        json.encode(BusinessWebsites[data.businessId]),
        data.businessId
    })
    
    -- Generate actual HTML file
    GenerateWebsiteHTML(data.businessId)
    
    TriggerClientEvent('QBCore:Notify', src, 'Website saved successfully!', 'success')
    TriggerClientEvent('qb-business:client:websiteSaved', src, BusinessWebsites[data.businessId])
end)

-- Process Online Order
RegisterNetEvent('qb-business:server:processOnlineOrder', function(businessId, orderData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Businesses[businessId] then return end
    
    local order = {
        id = GenerateOrderId(),
        customer = Player.PlayerData.citizenid,
        customerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        businessId = businessId,
        items = orderData.items,
        total = orderData.total,
        status = "pending",
        timestamp = os.time(),
        delivery = orderData.delivery or false,
        notes = orderData.notes
    }
    
    -- Check if player has enough money
    if Player.PlayerData.money.bank < orderData.total then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        return
    end
    
    -- Process payment
    Player.Functions.RemoveMoney('bank', orderData.total)
    Businesses[businessId].money = Businesses[businessId].money + orderData.total
    
    -- Add to orders
    if not BusinessOrders[businessId] then
        BusinessOrders[businessId] = {}
    end
    table.insert(BusinessOrders[businessId], order)
    
    -- Update website analytics
    if BusinessWebsites[businessId] then
        BusinessWebsites[businessId].analytics.orders = BusinessWebsites[businessId].analytics.orders + 1
        BusinessWebsites[businessId].analytics.revenue = BusinessWebsites[businessId].analytics.revenue + orderData.total
    end
    
    -- Notify business owner and employees
    NotifyBusinessStaff(businessId, 'New online order received! Order #' .. order.id)
    
    TriggerClientEvent('QBCore:Notify', src, 'Order placed successfully! Order #' .. order.id, 'success')
    TriggerClientEvent('qb-business:client:orderConfirmation', src, order)
end)

-- Generate Website HTML
function GenerateWebsiteHTML(businessId)
    local business = Businesses[businessId]
    local website = BusinessWebsites[businessId]
    
    if not business or not website then return end
    
    local template = Config.WebsiteTemplates[website.template]
    local html = LoadTemplate(template.baseHTML)
    
    -- Replace placeholders with actual content
    html = string.gsub(html, "{{BUSINESS_NAME}}", business.name)
    html = string.gsub(html, "{{BUSINESS_DESCRIPTION}}", website.content.description or "")
    html = string.gsub(html, "{{PRIMARY_COLOR}}", website.customization.primaryColor or "#007bff")
    html = string.gsub(html, "{{SECONDARY_COLOR}}", website.customization.secondaryColor or "#6c757d")
    html = string.gsub(html, "{{LOGO_URL}}", website.customization.logo or "default-logo.png")
    html = string.gsub(html, "{{BANNER_URL}}", website.customization.banner or "default-banner.jpg")
    
    -- Generate products section
    local productsHTML = ""
    if website.products then
        for _, product in ipairs(website.products) do
            productsHTML = productsHTML .. string.format([[
                <div class="product-card">
                    <img src="%s" alt="%s">
                    <h3>%s</h3>
                    <p>%s</p>
                    <span class="price">$%d</span>
                    <button onclick="addToCart('%s', '%s', %d)">Add to Cart</button>
                </div>
            ]], product.image or "default-product.png", product.name, product.name, 
                product.description or "", product.price, businessId, product.id, product.price)
        end
    end
    html = string.gsub(html, "{{PRODUCTS}}", productsHTML)
    
    -- Save HTML file
    SaveWebsiteFile(businessId, html)
    
    -- Update in-game browser cache
    TriggerClientEvent('qb-business:client:updateWebsiteCache', -1, businessId, website.domain)
end

-- Employee Management
RegisterNetEvent('qb-business:server:hireEmployee', function(businessId, targetId, role, salary)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if not Businesses[businessId] or Businesses[businessId].owner ~= Player.PlayerData.citizenid then
        return
    end
    
    local businessType = Config.BusinessTypes[Businesses[businessId].type]
    if #Businesses[businessId].employees >= businessType.maxEmployees then
        TriggerClientEvent('QBCore:Notify', src, 'Maximum employees reached', 'error')
        return
    end
    
    table.insert(Businesses[businessId].employees, {
        citizenid = Target.PlayerData.citizenid,
        name = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
        role = role,
        salary = salary,
        hired = os.time(),
        lastPaid = os.time(),
        permissions = GetRolePermissions(role)
    })
    
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been hired at ' .. Businesses[businessId].name, 'success')
    TriggerClientEvent('QBCore:Notify', src, 'Employee hired successfully', 'success')
end)

-- Business Analytics
RegisterNetEvent('qb-business:server:getAnalytics', function(businessId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Businesses[businessId] then return end
    
    -- Check permissions
    if not HasBusinessAccess(Player.PlayerData.citizenid, businessId, 'analytics') then
        TriggerClientEvent('QBCore:Notify', src, 'No permission to view analytics', 'error')
        return
    end
    
    local analytics = {
        revenue = {
            today = CalculateDailyRevenue(businessId),
            week = CalculateWeeklyRevenue(businessId),
            month = CalculateMonthlyRevenue(businessId)
        },
        customers = {
            total = Businesses[businessId].customers,
            returning = CalculateReturningCustomers(businessId),
            satisfaction = Businesses[businessId].reputation
        },
        website = BusinessWebsites[businessId] and BusinessWebsites[businessId].analytics or nil,
        topProducts = GetTopSellingProducts(businessId),
        expenses = CalculateExpenses(businessId)
    }
    
    TriggerClientEvent('qb-business:client:showAnalytics', src, analytics)
end)

-- Helper Functions
function GenerateBusinessId()
    return 'BUS-' .. math.random(10000, 99999) .. '-' .. os.time()
end

function GenerateOrderId()
    return 'ORD-' .. math.random(10000, 99999)
end

function GenerateDomain(businessName)
    local domain = string.lower(string.gsub(businessName, " ", "-"))
    return domain .. ".losantos.com"
end

function CreateDefaultWebsite(businessId)
    BusinessWebsites[businessId] = {
        template = "minimal",
        customization = {
            primaryColor = "#007bff",
            secondaryColor = "#6c757d",
            logo = "default-logo.png",
            banner = "default-banner.jpg"
        },
        content = {
            description = "Welcome to " .. Businesses[businessId].name,
            about = "We are a new business in Los Santos",
            contact = {
                phone = "555-0100",
                email = "info@" .. GenerateDomain(Businesses[businessId].name)
            }
        },
        products = {},
        isLive = false,
        domain = GenerateDomain(Businesses[businessId].name),
        analytics = {
            visits = 0,
            orders = 0,
            revenue = 0
        }
    }
end

function HasBusinessAccess(citizenid, businessId, permission)
    local business = Businesses[businessId]
    if not business then return false end
    
    if business.owner == citizenid then return true end
    
    for _, employee in ipairs(business.employees) do
        if employee.citizenid == citizenid then
            return employee.permissions[permission] or false
        end
    end
    
    return false
end

function GetRolePermissions(role)
    local permissions = {
        manager = {
            hire = true,
            fire = true,
            inventory = true,
            orders = true,
            analytics = true,
            website = true
        },
        employee = {
            inventory = true,
            orders = true
        },
        delivery = {
            orders = true,
            delivery = true
        }
    }
    
    return permissions[role] or permissions.employee
end

function NotifyBusinessStaff(businessId, message)
    local business = Businesses[businessId]
    if not business then return end
    
    -- Notify owner
    local owner = QBCore.Functions.GetPlayerByCitizenId(business.owner)
    if owner then
        TriggerClientEvent('QBCore:Notify', owner.PlayerData.source, message, 'info')
    end
    
    -- Notify employees
    for _, employee in ipairs(business.employees) do
        local emp = QBCore.Functions.GetPlayerByCitizenId(employee.citizenid)
        if emp then
            TriggerClientEvent('QBCore:Notify', emp.PlayerData.source, message, 'info')
        end
    end
end

-- Load businesses on resource start
CreateThread(function()
    MySQL.Async.fetchAll('SELECT * FROM player_businesses', {}, function(results)
        for _, business in ipairs(results) do
            Businesses[business.business_id] = json.decode(business.data)
            if business.website_data then
                BusinessWebsites[business.business_id] = json.decode(business.website_data)
            end
        end
        print('[QB-Business] Loaded ' .. #results .. ' businesses')
    end)
end)

-- Hourly business operations
CreateThread(function()
    while true do
        Wait(3600000) -- 1 hour
        
        for businessId, business in pairs(Businesses) do
            -- Pay employees
            for _, employee in ipairs(business.employees) do
                if os.time() - employee.lastPaid >= 86400 then -- 24 hours
                    if business.money >= employee.salary then
                        business.money = business.money - employee.salary
                        employee.lastPaid = os.time()
                        
                        local emp = QBCore.Functions.GetPlayerByCitizenId(employee.citizenid)
                        if emp then
                            emp.Functions.AddMoney('bank', employee.salary)
                            TriggerClientEvent('QBCore:Notify', emp.PlayerData.source, 
                                'Salary received: $' .. employee.salary, 'success')
                        end
                    end
                end
            end
            
            -- Generate passive income based on reputation and website traffic
            if business.isOpen then
                local income = CalculatePassiveIncome(businessId)
                business.money = business.money + income
            end
            
            -- Update database
            MySQL.Async.execute('UPDATE player_businesses SET data = ? WHERE business_id = ?', {
                json.encode(business),
                businessId
            })
        end
    end
end)

-- Export functions for other resources
exports('GetBusinessData', function(businessId)
    return Businesses[businessId]
end)

exports('GetBusinessWebsite', function(businessId)
    return BusinessWebsites[businessId]
end)

exports('IsBusinessOwner', function(citizenid, businessId)
    return Businesses[businessId] and Businesses[businessId].owner == citizenid
end)