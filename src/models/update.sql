CREATE TABLE `budget_ceiling` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `head` varchar(50) NOT NULL,
  `subhead` int(50) NOT NULL,
  `description` int(100) NOT NULL,
  `type` int(50) NOT NULL,
  `amt` bigint(20) NOT NULL,
  `total_amt` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `budget_ceiling`(IN `query_type` VARCHAR(50), IN `in_head` VARCHAR(30), IN `in_subhead` VARCHAR(50), IN `in_description` VARCHAR(100), IN `in_type` VARCHAR(30), IN `in_amt` BIGINT(20), IN `in_total_amt` BIGINT(20))
BEGIN
IF query_type='select' THEN
SELECT * FROM `account_chart` WHERE sub_head = '00000000000000000000';
ELSEIF query_type='insert' THEN
INSERT INTO `budget_ceiling`(head, subhead, description, type, amt, total_amt) VALUES (in_head, in_subhead, in_description, in_type, in_amt, in_total_amt);

END IF;
END$$
DELIMITER ;

-------

ALTER TABLE `budget_ceiling` CHANGE `subhead` `subhead` VARCHAR(50) NULL, CHANGE `type` `type` VARCHAR(50) NULL, CHANGE `description` `description` VARCHAR(100) NULL, CHANGE `created_at` `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;