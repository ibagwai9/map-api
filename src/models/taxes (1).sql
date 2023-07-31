-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 14, 2023 at 09:57 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `finance`
--

-- --------------------------------------------------------

--
-- Table structure for table `taxes`
--

CREATE TABLE `taxes` (
  `id` int(11) NOT NULL,
  `tax_code` varchar(51) DEFAULT NULL,
  `tax_parent_code` varchar(8) DEFAULT NULL,
  `description` varchar(65) DEFAULT NULL,
  `tax_fee` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `taxes`
--

INSERT INTO `taxes` (`id`, `tax_code`, `tax_parent_code`, `description`, `tax_fee`) VALUES
(1, '120101', '', 'PERSONAL TAX (PAYE) - GENERAL', '6000'),
(2, '12010101', '120101', 'Pay-as-You Earn- Public State', '6000'),
(3, '12010104', '120101', 'PAYE Public - Local Govts.', '6000'),
(4, '12010105', '120101', 'PAYE Federal Govt. Establishments', '6000'),
(5, '12010106', '120101', 'PAYE -Organised Private Sector', '6000'),
(6, '12010107', '120101', 'PAYE Informal Sector', '6000'),
(7, '112010110', '', 'Tax Audit / Back Duty Recovery', '6000'),
(8, 'DIRECT ASESSEMENT (SELF-EMP)', '12010500', NULL, '6000'),
(9, '12010500', '', 'Direct Assessment', '6000'),
(10, '12010501', '12010500', 'Direct Assessment on Affluent Affluent', '6000'),
(11, '12010502', '12010500', 'Direct Assessment on Mix-Income', '6000'),
(12, '12010503', '12010500', 'Direct Assessment on Expatriates', '6000'),
(13, '12010504', '12010500', 'Direct Assessment on Informal Sector', '6000'),
(15, 'WITHOLDING TAX - GEN', '12010400', NULL, '6000'),
(16, '12010401', '12010400', 'Withholding Tax on Dividend', '6000'),
(17, '12010402', '12010400', 'Withholding Tax on Rent', '6000'),
(18, '12010403', '12010400', 'Withholding Tax on Bank Interest', '6000'),
(19, '12010404', '12010400', 'Withholding Tax on Directors Fees', '6000'),
(20, '12010405', '12010400', 'Withholding Tax on Contracts', '6000'),
(21, '12010406', '12010400', 'Withholding Tax on Professional fees', '6000'),
(22, '12010407', '12010400', 'Withholding Tax on Management Fees', '6000'),
(23, '12010408', '12010400', 'Other Withholding Tax', '6000'),
(24, 'Capital Gains Tax (IND)', '120003', NULL, '6000'),
(25, '120003', '120003', 'Sale of Physical Assets ( Plant, Machinery & Equipment)', '6000'),
(26, '120103', '120003', 'Sale of Technical Knowhow (Technology Process or Design )', '6000'),
(27, '120203', '120003', 'Sale of Intellectual Property (Copy Right, Trade Marks & Patents)', '6000'),
(28, '12010602', '120003', '5tamp Duties on Instruments executed by individuals,', '6000'),
(29, '12010603', '120003', 'Development Levy', '6000'),
(30, '12020455', '120003', 'Entertainment levy', '6000'),
(31, '12020455', '120003', 'Social Services and Economic Levy', '6000'),
(32, 'PERSONAL INCOME TAX', '12010504', NULL, NULL),
(33, '12010504', '12010504', 'Boutique and other sellers - adults and children', '10,000.00'),
(34, '12010504', '12010504', 'Boutique and other sellers - adults and children', '30,000.00'),
(35, '12010504', '12010504', 'Fabricating, Welding, Milling, Black Smith, Gold oe Smith', '4,000.00'),
(36, '12010504', '12010504', 'Fabricating, Welding, Milling, Black Smith, Gold oe Smith', '15,000.00'),
(37, '12010504', '12010504', 'Fabricating, Welding, Milling, Black Smith, Gold oe Smith', '30,000.00'),
(38, '12010504', '12010504', 'Confectionaries and Bakeries', '25,000.00'),
(39, '12010504', '12010504', 'Confectionaries and Bakeries', '17,010.00'),
(40, '12010504', '12010504', 'Confectionaries and Bakeries', '15,000.00'),
(41, '12010504', '12010504', 'Business Centers, Typing Studios, Printers, Thrift 0, Collectors ', '4,000.00'),
(42, '12010504', '12010504', 'Business Centers, Typing Studios, Printers, Thrift 0, Collectors ', '10,000.00'),
(43, '12010504', '12010504', 'Business Centers, Typing Studios, Printers, Thrift 0, Collectors ', '20,000.00'),
(44, '12010504', '12010504', 'Video Clubs, Car Wash Owners, Cyber-cafe Operators', '4,000.00'),
(45, '12010504', '12010504', 'Video Clubs, Car Wash Owners, Cyber-cafe Operators', '10,000.00'),
(46, '12010504', '12010504', 'Video Clubs, Car Wash Owners, Cyber-cafe Operators', '25,000.00'),
(47, '12010504', '12010504', 'Drama Group, Laundries, Dry Cleaners, Commercial Mobile Calls', '4,000.00'),
(48, '12010504', '12010504', 'Drama Group, Laundries, Dry Cleaners, Commercial Mobile Calls', '10,000.00'),
(49, '12010504', '12010504', 'Drama Group, Laundries, Dry Cleaners, Commercial Mobile Calls', '25,000.00'),
(50, '12010504', '12010504', 'Photographers/Photo Developers, Recreational Centers, Refuse, Ren', '4,000.00'),
(51, '12010504', '12010504', 'Photographers/Photo Developers, Recreational Centers, Refuse, Ren', '20,000.00'),
(52, '12010504', '12010504', 'Photographers/Photo Developers, Recreational Centers, Refuse, Ren', '40,000.00'),
(53, '12010504', '12010504', 'Artisans - Masons, Vulcanizes, Iron Benders, Carpenters, Cobblers', '4,000.00'),
(54, '12010504', '12010504', 'Artisans - Masons, Vulcanizes, Iron Benders, Carpenters, Cobblers', '15,000.00'),
(55, '12010504', '12010504', 'Artisans - Masons, Vulcanizes, Iron Benders, Carpenters, Cobblers', '40,000.00'),
(56, '12010504', '12010504', 'Kerosene and Lubricant', '4,000.00'),
(57, '12010504', '12010504', 'Kerosene and Lubricant', '8,000.00'),
(58, '12010504', '12010504', 'Kerosene and Lubricant', '50,000.00'),
(59, '12010504', '12010504', 'Tailoring, Interior Decorations, Fashion Designers and Garment Ma', '4,000.00'),
(60, '12010504', '12010504', 'Tailoring, Interior Decorations, Fashion Designers and Garment Ma', '10,000.00'),
(61, '12010504', '12010504', 'Tailoring, Interior Decorations, Fashion Designers and Garment Ma', '25,000.00'),
(62, '12010504', '12010504', 'Transport Workers - Taxi, Bus, Lorry etc.', '4,000.00'),
(63, '12010504', '12010504', 'Transport Workers - Taxi, Bus, Lorry etc.', '7,000.00'),
(64, '12010504', '12010504', 'Transport Workers - Taxi, Bus, Lorry etc.', '20,000.00'),
(65, '12010504', '12010504', 'Trading/Enterprises - Retail and Wholesale Raw', '4,000.00'),
(66, '12010504', '12010504', 'Trading/Enterprises - Retail and Wholesale Raw', '8,000.00'),
(67, '12010504', '12010504', 'Trading/Enterprises - Retail and Wholesale Raw', '20,000.00'),
(68, '12010504', '12010504', 'Bookshops/Stationery Store, Building Materials, Cement, Cooking g', '4,000.00'),
(69, '12010504', '12010504', 'Bookshops/Stationery Store, Building Materials, Cement, Cooking g', '10,000.00'),
(70, '12010504', '12010504', 'Bookshops/Stationery Store, Building Materials, Cement, Cooking g', '20,000.00'),
(71, '12010504', '12010504', 'Furniture or Furnishing Material, Gas Refilling, General Contract', '4,000.00'),
(72, '12010504', '12010504', 'Furniture or Furnishing Material, Gas Refilling, General Contract', '10,000.00'),
(73, '12010504', '12010504', 'Furniture or Furnishing Material, Gas Refilling, General Contract', '20,000.00'),
(74, '12010504', '12010504', 'Medicine, Photographic Materials, Plank, Plastic Rubbers', '4,000.00'),
(75, '12010504', '12010504', 'Medicine, Photographic Materials, Plank, Plastic Rubbers', '10,000.00'),
(76, '12010504', '12010504', 'Medicine, Photographic Materials, Plank, Plastic Rubbers', '20,000.00'),
(77, '12010504', '12010504', 'Plumbing Materials, Poultry Feeds, Raw Food, Rugs and Carpets, Se', '4,000.00'),
(78, '12010504', '12010504', 'Plumbing Materials, Poultry Feeds, Raw Food, Rugs and Carpets, Se', '10,000.00'),
(79, '12010504', '12010504', 'Plumbing Materials, Poultry Feeds, Raw Food, Rugs and Carpets, Se', '20,000.00'),
(80, '12010504', '12010504', 'Timber Dealers, Tire and Processors, Producers and Manufacturers ', '4,000.00'),
(81, '12010504', '12010504', 'Timber Dealers, Tire and Processors, Producers and Manufacturers ', '10,000.00'),
(82, '12010504', '12010504', 'Timber Dealers, Tire and Processors, Producers and Manufacturers ', '30,000.00'),
(83, '12010504', '12010504', 'Allother trades/services covered by the law but not listed above', '4,000.00'),
(84, '12010504', '12010504', 'Allother trades/services covered by the law but not listed above', '10,000.00'),
(85, '12010504', '12010504', 'Allother trades/services covered by the law but not listed above', '20,000.00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `taxes`
--
ALTER TABLE `taxes`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `taxes`
--
ALTER TABLE `taxes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
