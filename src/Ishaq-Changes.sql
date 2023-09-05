ALTER TABLE `presumptive_taxes` CHANGE `revenue_code` `economic_code` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL, CHANGE `trade` `title` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;

ALTER TABLE `presumptive_taxes` DROP PRIMARY KEY; 

ALTER TABLE `presumptive_taxes` ADD `id` INT(6) NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);

ALTER TABLE `presumptive_taxes` ADD UNIQUE(`title`);

