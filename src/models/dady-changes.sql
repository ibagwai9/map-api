CREATE TABLE `mda_list` (
  `mda_name` varchar(100) NOT NULL,
  `mda_code` varchar(100) NOT NULL,
  `item_code` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `mda_list` ADD `code` VARCHAR(100) NOT NULL AFTER `item_code`, ADD `date` VARCHAR(100) NOT NULL AFTER `code`, ADD `quantity` VARCHAR(100) NOT NULL AFTER `date`, ADD `reciept_type` VARCHAR(100) NOT NULL AFTER `quantity`;
ALTER TABLE `mda_list` ADD `type` VARCHAR(100) NOT NULL AFTER `reciept_type`;