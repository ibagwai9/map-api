DROP  PROCEDURE IF EXISTS `insert_transactions`;
DELIMITER $$
CREATE  PROCEDURE `insert_transactions`(IN `in_transactioncount` INT, IN `in_status` VARCHAR(100), IN `in_surname` VARCHAR(100), IN `in_othernames` VARCHAR(100), IN `in_paymentdate` DATE, IN `in_paymentmethod` VARCHAR(100), IN `in_localid` VARCHAR(100), IN `in_onlineid` VARCHAR(100), IN `in_bank_teller` VARCHAR(100), IN `in_hospital_invoice` VARCHAR(100), IN `in_total_amount` DECIMAL, IN `in_hospital` VARCHAR(100), IN `in_description` VARCHAR(100), IN `in_amount` DECIMAL, IN `in_department` VARCHAR(100), IN `in_unit` VARCHAR(100))
INSERT INTO `transactions`(`transactioncount`, `status`, `surname`, `othernames`, `paymentdate`, `paymentmethod`, `localid`, `onlineid`, `bank_teller`, `hospital_invoice`, `total_amount`, `hospital`, `description`, `amount`, `department`, `unit`) VALUES (in_transactioncount,in_status,in_surname,in_othernames,in_paymentdate,in_paymentmethod,in_localid,in_onlineid,in_bank_teller,in_hospital_invoice,in_total_amount,in_hospital,in_description,in_amount,in_department,in_unit)$$
DELIMITER ;

-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 11, 2023 at 12:08 AM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 8.1.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `finance_2`
--

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `transactioncount` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  `othernames` varchar(255) DEFAULT NULL,
  `paymentdate` datetime DEFAULT NULL,
  `paymentmethod` varchar(255) DEFAULT NULL,
  `localid` varchar(255) DEFAULT NULL,
  `onlineid` varchar(255) DEFAULT NULL,
  `bank_teller` varchar(255) DEFAULT NULL,
  `hospital_invoice` varchar(255) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `hospital` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transactions`
--

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
