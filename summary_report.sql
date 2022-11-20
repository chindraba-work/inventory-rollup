-- SPDX-License-Identifier: MIT
SELECT
    DATEDIFF(DATE(NOW()),`InventoryIssue_Collection`.`date`) DIV 7 AS `Age`,
    `Technician`.`name` AS `Tech`,
    `Item`.`name` AS `Item`,
    SUM(`quantity`) AS `Sold`
FROM `InventoryIssue_Collection`
JOIN `Technician`
    ON `Technician`.`code` = `InventoryIssue_Collection`.`techId`
JOIN `Item`
    ON `Item`.`id` = `InventoryIssue_Collection`.`itemId`
GROUP BY `Item`.`id`,`Age`,`Tech`
    WITH ROLLUP;
