-- SPDX-License-Identifier: MIT
CREATE SCHEMA INVENTORY_USAGE

GO

USE INVENTORY_USAGE

DROP TABLE IF EXISTS `Technician`

GO

CREATE TABLE `Technician`
(
    `code`  INTEGER(5) UNSIGNED NOT NULL,
--        $event_data[2]
    `name` VARCHAR(50) NOT NULL,
--        $event_data[1]
    PRIMARY KEY (`code`),
    UNIQUE KEY `key_technician_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Technicians who have signed out equipment from here'

GO

DROP TABLE IF EXISTS `ItemClass`

GO

CREATE TABLE `ItemClass`
(
    `id` SERIAL,
    `name` VARCHAR(50) NOT NULL,
--        $event_data[4]
    PRIMARY KEY (`id`),
    UNIQUE KEY `key_item_class` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='How Pixsys has the items grouped'

GO

DROP TABLE IF EXISTS `Item`

GO

CREATE TABLE `Item`
(   
    `id` SERIAL,
    `name` VARCHAR(50)  NOT NULL,
--        $event_data[3]
    `classId` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `item_class_fk` FOREIGN KEY (`classId`) REFERENCES `ItemClass` (`id`),
    UNIQUE KEY `key_item_name` (`classId`, `name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Inventoriable items'

GO

DROP TABLE IF EXISTS `InventoryIssue_Callout`

GO

CREATE TABLE `InventoryIssue_Callout`
(
    `date` DATE NOT NULL,
--        $event_data[0]
    `techId` INTEGER(5) UNSIGNED NOT NULL,
    `itemId` BIGINT UNSIGNED NOT NULL,
    `quantity` INTEGER(4) NOT NULL,
--        $event_data[5]
    PRIMARY KEY (`date`,`techId`,`itemId`),
    CONSTRAINT `callout_tech_fk` FOREIGN KEY (`techId`) REFERENCES `Technician` (`code`),
    CONSTRAINT `callout_item_fk` FOREIGN KEY (`itemId`) REFERENCES `Item` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Items assigned in bulk, without serial numbers'

GO

DROP TABLE IF EXISTS `InventoryIssue_Serialized`

GO

CREATE TABLE `InventoryIssue_Serialized`
(
    `date` DATE NOT NULL,
--        $event_data[0]
    `techId` INTEGER UNSIGNED NOT NULL,
    `itemId` BIGINT UNSIGNED NOT NULL,
    `serial` VARCHAR(30) NOT NULL,
--        $event_data[5]
    PRIMARY KEY (`date`, `techId`, `itemId`, `serial`),
    UNIQUE INDEX `idx_serail` (`serial`),
    CONSTRAINT `serialized_tech_fk` FOREIGN KEY (`techId`) REFERENCES `Technician` (`code`),
    CONSTRAINT `serialized_item_fk` FOREIGN KEY (`itemId`) REFERENCES `Item` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Items assigned individually with serial numbers'

GO

CREATE OR REPLACE VIEW `InventoryIssue_Collection`
(
    `date`,
    `techId`,
    `itemId`,
    `quantity`
) AS SELECT
    `date`,
    `techId`,
    `itemId`,
    `quantity`
FROM `InventoryIssue_Callout`
UNION SELECT 
    `date`,
    `techId`,
    `itemId`,
    count(*)
FROM `InventoryIssue_Serialized`
GROUP BY
    `date`,
    `techId`,
    `itemId`

GO

CREATE USER 'inventory'@'localhost' IDENTIFIED BY 'passwd'

GO

GRANT USAGE ON *.* to 'inventory'@'localhost'

GO

GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT ON `INVENTORY_USAGE`.* TO 'inventory'@'localhost' WITH GRANT OPTION

GO
