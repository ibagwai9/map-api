CREATE TABLE `mda_list` (
  `mda_name` varchar(100) NOT NULL,
  `mda_code` varchar(100) NOT NULL,
  `item_code` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;