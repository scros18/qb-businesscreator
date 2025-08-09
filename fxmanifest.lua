-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'QB-Core Business Creator'
description 'Advanced Dynamic Business Creation System with Website Builder'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/management.lua',
    'client/websites.lua',
    'client/utils.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/websites.lua',
    'server/orders.lua',
    'server/analytics.lua',
    'server/utils.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/templates/*.html'
}

dependencies {
    'qb-core',
    'qb-menu',
    'qb-target',
    'oxmysql'
}

lua54 'yes'

-- config.lua
Config = {}

-- General Settings
Config.Debug = false
Config.MaxBusinessesPerPlayer = 3
Config.BusinessCreationCooldown = 86400 -- 24 hours in seconds
Config.RequireBusinessLicense = true
Config.TaxRate = 0.15 -- 15% tax on profits

-- Website Builder Settings
Config.WebsiteBuilder = {
    MaxProductsPerSite = 50,
    MaxImagesPerSite = 20,
    ImageSizeLimit = 2097152, -- 2MB in bytes
    AllowedImageFormats = {'png', 'jpg', 'jpeg', 'gif', 'webp'},
    DomainSuffix = '.losantos.com',
    HostingCostPerDay = 50,
    SSLCertificateCost = 500,
    CDNCost = 100, -- per day for faster loading
}

-- Computer Locations for Website Builder
Config.ComputerLocations = {
    {coords = vector3(-1081.85, -248.31, 37.76), heading = 45.0, label = "Life Invader Office"},
    {coords = vector3(-1371.42, -457.89, 34.48), heading = 180.0, label = "Downtown Office"},
    {coords = vector3(1272.37, -1711.74, 54.77), heading = 90.0, label = "Lester's House"},
    {coords = vector3(-618.75, -929.88, 23.18), heading = 270.0, label = "Internet Cafe"},
    {coords = vector3(736.21, 132.56, 80.72), heading = 330.0, label = "Power Street Office"},
    -- Add library computers for public access
    {coords = vector3(1137.77, -978.12, 46.41), heading = 100.0, label = "Public Library"},
}

-- Business Types Configuration
Config.BusinessTypes = {
    -- Legal Businesses
    restaurant = {
        name = "Restaurant",
        legal = true,
        basePrice = 150000,
        maxEmployees = 8,
        dailyUpkeep = 500,
        baseIncome = 2000,
        requiredLicense = "business_food",
        features = {
            website = true,
            onlineOrders = true,
            delivery = true,
            reservations = true,
            reviews = true
        },
        products = {
            {id = "burger", name = "Burger", basePrice = 15, craftTime = 10},
            {id = "pizza", name = "Pizza", basePrice = 20, craftTime = 15},
            {id = "pasta", name = "Pasta", basePrice = 18, craftTime = 12},
            {id = "salad", name = "Salad", basePrice = 12, craftTime = 5},
            {id = "drinks", name = "Drinks", basePrice = 5, craftTime = 2},
            {id = "dessert", name = "Dessert", basePrice = 10, craftTime = 8}
        },
        upgrades = {
            kitchen = {
                levels = 3,
                baseCost = 20000,
                effect = "production_speed",
                multiplier = {1.0, 1.25, 1.5}
            },
            seating = {
                levels = 3,
                baseCost = 15000,
                effect = "customer_capacity",
                multiplier = {20, 35, 50}
            },
            delivery = {
                levels = 2,
                baseCost = 25000,
                effect = "delivery_radius",
                multiplier = {1000, 2000}
            }
        }
    },
    
    nightclub = {
        name = "Nightclub",
        legal = true,
        basePrice = 500000,
        maxEmployees = 12,
        dailyUpkeep = 1500,
        baseIncome = 5000,
        requiredLicense = "business_entertainment",
        features = {
            website = true,
            ticketSales = true,
            vipBooking = true,
            eventCalendar = true,
            djBooth = true
        },
        products = {
            {id = "entry_regular", name = "Regular Entry", basePrice = 20},
            {id = "entry_vip", name = "VIP Entry", basePrice = 100},
            {id = "bottle_service", name = "Bottle Service", basePrice = 500},
            {id = "private_booth", name = "Private Booth", basePrice = 1000}
        },
        upgrades = {
            soundSystem = {
                levels = 3,
                baseCost = 50000,
                effect = "popularity",
                multiplier = {1.0, 1.3, 1.6}
            },
            lighting = {
                levels = 3,
                baseCost = 30000,
                effect = "ambiance",
                multiplier = {1.0, 1.2, 1.4}
            },
            security = {
                levels = 3,
                baseCost = 40000,
                effect = "safety",
                multiplier = {1.0, 1.5, 2.0}
            }
        }
    },
    
    mechanic = {
        name = "Mechanic Shop",
        legal = true,
        basePrice = 200000,
        maxEmployees = 6,
        dailyUpkeep = 800,
        baseIncome = 3000,
        requiredLicense = "business_mechanic",
        features = {
            website = true,
            appointmentBooking = true,
            partsCatalog = true,
            customization = true
        },
        products = {
            {id = "repair_basic", name = "Basic Repair", basePrice = 500},
            {id = "repair_engine", name = "Engine Repair", basePrice = 1500},
            {id = "repair_body", name = "Body Work", basePrice = 1000},
            {id = "upgrade_turbo", name = "Turbo Installation", basePrice = 5000},
            {id = "upgrade_armor", name = "Armor Plating", basePrice = 3000},
            {id = "custom_paint", name = "Custom Paint Job", basePrice = 2000}
        }
    },
    
    dealership = {
        name = "Vehicle Dealership",
        legal = true,
        basePrice = 1000000,
        maxEmployees = 10,
        dailyUpkeep = 3000,
        baseIncome = 10000,
        requiredLicense = "business_dealer",
        features = {
            website = true,
            vehicleShowcase = true,
            testDriveBooking = true,
            financing = true,
            tradeIn = true
        },
        vehicleCategories = {
            "Compacts", "Sedans", "SUVs", "Coupes", "Muscle", 
            "Sports", "Super", "Motorcycles", "Vans"
        }
    },
    
    carwash = {
        name = "Car Wash",
        legal = true,
        basePrice = 80000,
        maxEmployees = 4,
        dailyUpkeep = 300,
        baseIncome = 1500,
        requiredLicense = "business_general",
        features = {
            website = true,
            membershipProgram = true,
            autoScheduling = true
        },
        products = {
            {id = "basic_wash", name = "Basic Wash", basePrice = 10, duration = 5},
            {id = "premium_wash", name = "Premium Wash", basePrice = 25, duration = 10},
            {id = "deluxe_wash", name = "Deluxe Detail", basePrice = 50, duration = 20},
            {id = "monthly_pass", name = "Monthly Unlimited", basePrice = 100}
        }
    },
    
    -- Illegal Businesses (require VPN device)
    drugoperation = {
        name = "Pharmaceutical Distribution",
        legal = false,
        basePrice = 750000,
        maxEmployees = 6,
        dailyUpkeep = 2000,
        baseIncome = 15000,
        requiredLicense = nil,
        requiresVPN = true,
        raidChance = 0.05, -- 5% chance per day if not paying protection
        features = {
            website = true, -- Dark web only
            encryptedOrders = true,
            cryptoPayments = true,
            deadDrops = true
        },
        products = {
            {id = "product_alpha", name = "Alpha Package", basePrice = 500, risk = "high"},
            {id = "product_beta", name = "Beta Package", basePrice = 1000, risk = "very_high"},
            {id = "product_gamma", name = "Gamma Package", basePrice = 2000, risk = "extreme"}
        }
    },
    
    weaponsdealer = {
        name = "Security Consulting",
        legal = false,
        basePrice = 1500000,
        maxEmployees = 4,
        dailyUpkeep = 5000,
        baseIncome = 25000,
        requiredLicense = nil,
        requiresVPN = true,
        raidChance = 0.08,
        features = {
            website = true, -- Dark web only
            encryptedCatalog = true,
            deadDrops = true,
            customOrders = true
        }
    },
    
    moneylaundering = {
        name = "Financial Services",
        legal = false,
        basePrice = 2000000,
        maxEmployees = 2,
        dailyUpkeep = 10000,
        baseIncome = 0, -- Income from laundering fees
        requiredLicense = nil,
        requiresVPN = true,
        launderingFee = 0.15, -- 15% fee
        dailyLimit = 100000,
        features = {
            website = false,
            cryptoConversion = true,
            offshoreAccounts = true
        }
    }
}

-- Employee Roles and Permissions
Config.EmployeeRoles = {
    manager = {
        label = "Manager",
        permissions = {
            hire = true,
            fire = true,
            inventory = true,
            orders = true,
            analytics = true,
            website = true,
            banking = true,
            upgrades = true
        },
        maxSalary = 5000
    },
    supervisor = {
        label = "Supervisor",
        permissions = {
            hire = false,
            fire = false,
            inventory = true,
            orders = true,
            analytics = true,
            website = false,
            banking = false,
            upgrades = false
        },
        maxSalary = 3000
    },
    employee = {
        label = "Employee",
        permissions = {
            inventory = true,
            orders = true,
            analytics = false,
            website = false,
            banking = false
        },
        maxSalary = 2000
    },
    delivery = {
        label = "Delivery Driver",
        permissions = {
            orders = true,
            delivery = true
        },
        maxSalary = 1500
    }
}

-- Business Zones
Config.BusinessZones = {
    -- Popular business areas with bonuses
    {
        name = "Vinewood Boulevard",
        coords = vector3(287.45, 179.86, 104.29),
        radius = 200.0,
        bonus = {
            reputation = 1.2,
            customers = 1.3
        }
    },
    {
        name = "Del Perro Beach",
        coords = vector3(-1827.15, -1194.51, 14.31),
        radius = 300.0,
        bonus = {
            reputation = 1.1,
            customers = 1.4
        }
    },
    {
        name = "Downtown Los Santos",
        coords = vector3(-215.67, -1323.81, 30.89),
        radius = 400.0,
        bonus = {
            reputation = 1.15,
            customers = 1.25
        }
    }
}

-- Loyalty Program Tiers
Config.LoyaltyTiers = {
    bronze = {
        pointsRequired = 0,
        discount = 0,
        perks = {"Newsletter"}
    },
    silver = {
        pointsRequired = 500,
        discount = 5,
        perks = {"Newsletter", "Priority Support", "Birthday Bonus"}
    },
    gold = {
        pointsRequired = 2000,
        discount = 10,
        perks = {"Newsletter", "Priority Support", "Birthday Bonus", "Free Delivery", "Early Access"}
    },
    platinum = {
        pointsRequired = 5000,
        discount = 20,
        perks = {"Newsletter", "Priority Support", "Birthday Bonus", "Free Delivery", "Early Access", "VIP Events", "Personal Account Manager"}
    }
}

-- Marketing Campaign Effects
Config.MarketingCampaigns = {
    discount = {
        cost = 1000,
        duration = 86400, -- 24 hours
        effect = {
            customers = 1.3,
            reputation = 1.05
        }
    },
    bogo = {
        cost = 1500,
        duration = 43200, -- 12 hours
        effect = {
            customers = 1.5,
            reputation = 1.1
        }
    },
    seasonal = {
        cost = 2500,
        duration = 604800, -- 1 week
        effect = {
            customers = 1.2,
            reputation = 1.15
        }
    },
    social_media = {
        cost = 500,
        duration = 172800, -- 2 days
        effect = {
            customers = 1.15,
            reputation = 1.2,
            website_traffic = 1.5
        }
    },
    influencer = {
        cost = 5000,
        duration = 86400, -- 24 hours
        effect = {
            customers = 2.0,
            reputation = 1.3,
            website_traffic = 2.5
        }
    }
}

-- Business License Costs and Requirements
Config.Licenses = {
    business_general = {
        label = "General Business License",
        cost = 5000,
        duration = 2592000, -- 30 days
        requirements = {
            level = 0,
            items = {}
        }
    },
    business_food = {
        label = "Food Service License",
        cost = 10000,
        duration = 2592000,
        requirements = {
            level = 5,
            items = {"health_certificate"}
        }
    },
    business_entertainment = {
        label = "Entertainment License",
        cost = 15000,
        duration = 2592000,
        requirements = {
            level = 10,
            items = {"liquor_license"}
        }
    },
    business_mechanic = {
        label = "Automotive Service License",
        cost = 12000,
        duration = 2592000,
        requirements = {
            level = 8,
            items = {"mechanic_certification"}
        }
    },
    business_dealer = {
        label = "Vehicle Dealer License",
        cost = 25000,
        duration = 2592000,
        requirements = {
            level = 15,
            items = {"dealer_bond"}
        }
    }
}

-- Delivery Configuration
Config.Delivery = {
    VehicleModel = 'rumpo',
    MaxDistance = 2000, -- meters
    TimeLimit = 600, -- 10 minutes
    PaymentPerDelivery = 50,
    BonusForSpeed = 25,
    FuelCost = 10
}

-- Analytics Configuration
Config.Analytics = {
    UpdateInterval = 3600, -- Update every hour
    RetentionDays = 30, -- Keep data for 30 days
    MetricsTracked = {
        "revenue",
        "expenses",
        "profit",
        "customers",
        "orders",
        "website_visits",
        "conversion_rate",
        "average_order_value",
        "employee_productivity",
        "inventory_turnover"
    }
}

-- Notification Messages
Config.Messages = {
    NoMoney = "Insufficient funds for this purchase",
    BusinessCreated = "Congratulations! Your business has been created",
    EmployeeHired = "New employee hired successfully",
    EmployeeFired = "Employee has been terminated",
    WebsiteLive = "Your website is now live at: ",
    OrderReceived = "New order received! Check your management panel",
    DeliveryComplete = "Delivery completed successfully",
    UpgradePurchased = "Business upgrade purchased!",
    LicenseExpired = "Your business license has expired!",
    TaxesDue = "Business taxes are due: $",
    RaidWarning = "⚠️ Law enforcement is investigating your business!",
    MaintenanceRequired = "Your business requires maintenance"
}

-- UI Configuration
Config.UI = {
    MenuAlign = 'top-left',
    ProgressBarColor = '#667eea',
    NotificationPosition = 'top-right',
    DefaultWebsiteTheme = 'modern',
    AnimationSpeed = 300
}

-- Blip Configuration
Config.Blips = {
    BusinessCreation = {
        sprite = 408,
        color = 2,
        scale = 0.8,
        label = "Business Registration"
    },
    OwnedBusiness = {
        sprite = 374,
        color = 3,
        scale = 0.9
    },
    PartnerBusiness = {
        sprite = 374,
        color = 5,
        scale = 0.7
    }
}

-- Business Creation Locations
Config.CreationLocations = {
    {
        coords = vector3(-267.94, -957.33, 31.22),
        heading = 205.0,
        label = "City Hall - Business Registration",
        blip = true
    },
    {
        coords = vector3(-1371.42, -457.89, 34.48),
        heading = 180.0,
        label = "Downtown Business Center",
        blip = true
    }
}

-- VPN Device Settings (for illegal businesses)
Config.VPNDevice = {
    ItemName = "vpn_device",
    ConnectionTime = 5, -- seconds
    TraceChance = 0.02, -- 2% chance of being traced per use
    RequiredForDarkWeb = true
}

-- Protection Money (for illegal businesses)
Config.Protection = {
    WeeklyCost = 10000,
    Collector = "mafia", -- job name
    ReducesRaidChance = 0.75 -- Reduces raid chance by 75%
}

-- Business Interactions
Config.Interactions = {
    ManagementDistance = 3.0,
    CustomerDistance = 5.0,
    DeliveryDistance = 10.0,
    UseTarget = true, -- Use qb-target instead of DrawText
    Keys = {
        Interact = 38, -- E
        Cancel = 73, -- X
        Management = 167 -- F6
    }
}

-- Performance Settings
Config.Performance = {
    MaxRenderDistance = 100.0,
    UpdateInterval = 1000, -- milliseconds
    MaxConcurrentWebsites = 50,
    CacheWebsites = true,
    DatabaseBatchSize = 100
}

-- Developer/Debug Settings
Config.Developer = {
    TestMode = false,
    SkipPayments = false,
    InstantDelivery = false,
    ShowZones = false,
    LogLevel = "info" -- "debug", "info", "warn", "error"
}