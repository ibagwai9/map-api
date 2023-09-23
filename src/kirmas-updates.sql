

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 18, 2023 at 06:46 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
ALTER TABLE `lgas` ADD `geo_code` VARCHAR(20) NULL DEFAULT NULL AFTER `state`;
DELETE FROM `lgas` WHERE state='Kano state';
INSERT INTO `lgas` (`geo_code`, `lga_name`, `state`) VALUES
(31930100, 'Ajingi', 'Kano state'),
(31930200, 'Albasu', 'Kano state'),
(31920300, 'Bagwai', 'Kano state'),
(31930400, 'Bebeji', 'Kano state'),
(31920500, 'Bichi', 'Kano state'),
(31930600, 'Bunkure', 'Kano state'),
(31910900, 'Dawakin Kudu', 'Kano state'),
(31921000, 'Dawakin Tofa', 'Kano state'),
(31910700, 'Dala', 'Kano state'),
(31920800, 'Danbatta', 'Kano state'),
(31931100, 'Doguwa', 'Kano state'),
(31911200, 'Fagge', 'Kano state'),
(31931500, 'Garun Malam', 'Kano state'),
(31911300, 'Gabasawa', 'Kano state'),
(31931400, 'Garko', 'Kano state'),
(31931600, 'Gaya', 'Kano state'),
(31911700, 'Gezawa', 'Kano state'),
(31911800, 'Gwale', 'Kano state'),
(31921900, 'Gwarzo', 'Kano state'),
(31922000, 'Kabo', 'Kano state'),
(31912100, 'Kano state Municipal', 'Kano state'),
(31932200, 'Karaye', 'Kano state'),
(31932300, 'Kibiya', 'Kano state'),
(31932400, 'Kiru', 'Kano state'),
(31912500, 'Kumbotso', 'Kano state'),
(31922600, 'Kunchi', 'Kano state'),
(31912700, 'Kura', 'Kano state'),
(31912800, 'Madobi', 'Kano state'),
(31922900, 'Makoda', 'Kano state'),
(31923000, 'Minjibir', 'Kano state'),
(31913100, 'Nassarawa', 'Kano state'),
(31923300, 'Rimin Gado', 'Kano state'),
(31933200, 'Rano', 'Kano state'),
(31933400, 'Rogo', 'Kano state'),
(31923500, 'Shanono', 'Kano state'),
(31933600, 'Sumaila', 'Kano state'),
(31934100, 'Tudun Wada', 'Kano state'),
(31933700, 'Takai', 'Kano state'),
(31913800, 'Tarauni', 'Kano state'),
(31923900, 'Tofa', 'Kano state'),
(31924000, 'Tsanyawa', 'Kano state'),
(31914200, 'Ungogo', 'Kano state'),
(31914300, 'Warawa', 'Kano state'),
(31934400, 'Wudil', 'Kano state');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;