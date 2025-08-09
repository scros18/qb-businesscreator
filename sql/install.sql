-- QB-Core Business Creator System Database Structure
-- Run this SQL in your FiveM database

-- Main business table
CREATE TABLE IF NOT EXISTS `player_businesses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `owner` varchar(50) NOT NULL,
    `name` varchar(100) NOT NULL,
    `type` varchar(50) NOT NULL,
    `location` longtext DEFAULT NULL,
    `data` longtext DEFAULT NULL,
    `website_data` longtext DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `business_id` (`business_id`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business employees table
CREATE TABLE IF NOT EXISTS `business_employees` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `citizen_id` varchar(50) NOT NULL,
    `role` varchar(50) NOT NULL DEFAULT 'employee',
    `salary` int(11) NOT NULL DEFAULT 0,
    `permissions` longtext DEFAULT NULL,
    `hired_date` timestamp NOT NULL DEFAULT current_timestamp(),
    `last_paid` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `citizen_id` (`citizen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business inventory table
CREATE TABLE IF NOT EXISTS `business_inventory` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `item_name` varchar(100) NOT NULL,
    `amount` int(11) NOT NULL DEFAULT 0,
    `price` decimal(10,2) DEFAULT NULL,
    `metadata` longtext DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `item_name` (`item_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business transactions table
CREATE TABLE IF NOT EXISTS `business_transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `type` enum('income','expense','salary','purchase','sale','tax') NOT NULL,
    `amount` decimal(10,2) NOT NULL,
    `description` varchar(255) DEFAULT NULL,
    `citizen_id` varchar(50) DEFAULT NULL,
    `metadata` longtext DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `type` (`type`),
    KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business orders table (for online orders)
CREATE TABLE IF NOT EXISTS `business_orders` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `order_id` varchar(50) NOT NULL,
    `business_id` varchar(50) NOT NULL,
    `customer_id` varchar(50) NOT NULL,
    `customer_name` varchar(100) DEFAULT NULL,
    `items` longtext NOT NULL,
    `total` decimal(10,2) NOT NULL,
    `status` enum('pending','preparing','ready','delivered','cancelled') NOT NULL DEFAULT 'pending',
    `delivery_address` varchar(255) DEFAULT NULL,
    `notes` text DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `order_id` (`order_id`),
    KEY `business_id` (`business_id`),
    KEY `customer_id` (`customer_id`),
    KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business websites table
CREATE TABLE IF NOT EXISTS `business_websites` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `domain` varchar(100) NOT NULL,
    `template` varchar(50) NOT NULL,
    `customization` longtext DEFAULT NULL,
    `content` longtext DEFAULT NULL,
    `products` longtext DEFAULT NULL,
    `seo_data` longtext DEFAULT NULL,
    `analytics` longtext DEFAULT NULL,
    `is_live` tinyint(1) NOT NULL DEFAULT 0,
    `requires_vpn` tinyint(1) NOT NULL DEFAULT 0,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `business_id` (`business_id`),
    UNIQUE KEY `domain` (`domain`),
    KEY `is_live` (`is_live`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business reviews/ratings table
CREATE TABLE IF NOT EXISTS `business_reviews` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `citizen_id` varchar(50) NOT NULL,
    `rating` int(11) NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
    `review` text DEFAULT NULL,
    `response` text DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `citizen_id` (`citizen_id`),
    KEY `rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business upgrades table
CREATE TABLE IF NOT EXISTS `business_upgrades` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `upgrade_type` varchar(50) NOT NULL,
    `level` int(11) NOT NULL DEFAULT 1,
    `purchased_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    UNIQUE KEY `business_upgrade` (`business_id`, `upgrade_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business analytics table
CREATE TABLE IF NOT EXISTS `business_analytics` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `date` date NOT NULL,
    `visitors` int(11) NOT NULL DEFAULT 0,
    `online_orders` int(11) NOT NULL DEFAULT 0,
    `in_store_sales` int(11) NOT NULL DEFAULT 0,
    `revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
    `expenses` decimal(10,2) NOT NULL DEFAULT 0.00,
    `unique_customers` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `business_date` (`business_id`, `date`),
    KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business partnerships table (for B2B)
CREATE TABLE IF NOT EXISTS `business_partnerships` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id_1` varchar(50) NOT NULL,
    `business_id_2` varchar(50) NOT NULL,
    `partnership_type` enum('supplier','distributor','affiliate','joint_venture') NOT NULL,
    `terms` longtext DEFAULT NULL,
    `revenue_share` decimal(5,2) DEFAULT NULL,
    `status` enum('pending','active','terminated') NOT NULL DEFAULT 'pending',
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id_1` (`business_id_1`),
    KEY `business_id_2` (`business_id_2`),
    KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business licenses table
CREATE TABLE IF NOT EXISTS `business_licenses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `license_type` varchar(50) NOT NULL,
    `issued_date` timestamp NOT NULL DEFAULT current_timestamp(),
    `expiry_date` timestamp NULL DEFAULT NULL,
    `issued_by` varchar(50) DEFAULT NULL,
    `status` enum('active','expired','revoked','suspended') NOT NULL DEFAULT 'active',
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `license_type` (`license_type`),
    KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business marketing campaigns table
CREATE TABLE IF NOT EXISTS `business_campaigns` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `campaign_name` varchar(100) NOT NULL,
    `campaign_type` enum('discount','bogo','seasonal','loyalty','referral') NOT NULL,
    `discount_percent` int(11) DEFAULT NULL,
    `start_date` timestamp NOT NULL DEFAULT current_timestamp(),
    `end_date` timestamp NULL DEFAULT NULL,
    `budget` decimal(10,2) DEFAULT NULL,
    `target_audience` varchar(255) DEFAULT NULL,
    `is_active` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `is_active` (`is_active`),
    KEY `campaign_dates` (`start_date`, `end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business customer loyalty table
CREATE TABLE IF NOT EXISTS `business_loyalty` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `citizen_id` varchar(50) NOT NULL,
    `points` int(11) NOT NULL DEFAULT 0,
    `tier` enum('bronze','silver','gold','platinum') NOT NULL DEFAULT 'bronze',
    `total_spent` decimal(10,2) NOT NULL DEFAULT 0.00,
    `visits` int(11) NOT NULL DEFAULT 0,
    `last_visit` timestamp NULL DEFAULT NULL,
    `joined_date` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `business_customer` (`business_id`, `citizen_id`),
    KEY `tier` (`tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create indexes for better performance
CREATE INDEX idx_business_owner ON player_businesses(owner);
CREATE INDEX idx_business_type ON player_businesses(type);
CREATE INDEX idx_transaction_date ON business_transactions(created_at);
CREATE INDEX idx_order_status ON business_orders(status);
CREATE INDEX idx_website_live ON business_websites(is_live);

-- Sample data for testing (optional)
INSERT INTO `player_businesses` (`business_id`, `owner`, `name`, `type`, `data`) VALUES
('BUS-DEMO-001', 'ABC12345', 'Demo Restaurant', 'restaurant', '{"reputation": 75, "money": 50000, "isOpen": true}'),
('BUS-DEMO-002', 'XYZ67890', 'Demo Nightclub', 'nightclub', '{"reputation": 90, "money": 150000, "isOpen": true}');

-- Create views for common queries
CREATE VIEW business_overview AS
SELECT 
    pb.business_id,
    pb.name,
    pb.type,
    pb.owner,
    COUNT(DISTINCT be.citizen_id) as employee_count,
    COUNT(DISTINCT br.id) as review_count,
    AVG(br.rating) as avg_rating,
    bw.is_live as has_website
FROM player_businesses pb
LEFT JOIN business_employees be ON pb.business_id = be.business_id
LEFT JOIN business_reviews br ON pb.business_id = br.business_id
LEFT JOIN business_websites bw ON pb.business_id = bw.business_id
GROUP BY pb.business_id;

CREATE VIEW daily_revenue AS
SELECT 
    business_id,
    DATE(created_at) as date,
    SUM(CASE WHEN type = 'income' OR type = 'sale' THEN amount ELSE 0 END) as revenue,
    SUM(CASE WHEN type = 'expense' OR type = 'salary' OR type = 'tax' THEN amount ELSE 0 END) as expenses,
    SUM(CASE WHEN type = 'income' OR type = 'sale' THEN amount ELSE -amount END) as profit
FROM business_transactions
GROUP BY business_id, DATE(created_at);