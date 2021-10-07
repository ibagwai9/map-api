-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 16, 2021 at 04:38 PM
-- Server version: 10.1.38-MariaDB
-- PHP Version: 7.3.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `financial_mgt`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pv_collection` (IN `in_query_type` VARCHAR(400), IN `in_date` DATE, IN `in_pv_no` VARCHAR(400), IN `in_pv_date` VARCHAR(400), IN `in_computer_pv_no` VARCHAR(400), IN `in_project_type` VARCHAR(400), IN `in_project_name` VARCHAR(400), IN `in_mda_name` VARCHAR(400), IN `in_contractor_no` VARCHAR(400))  NO SQL
IF in_query_type = "insert" THEN

INSERT INTO pv_collection (date, pv_no, pv_date, computer_pv_no, project_type, project_name, mda_name, contractor_no) 

VALUES (in_date, in_pv_no, in_pv_date, in_computer_pv_no, in_project_type, in_project_name, in_mda_name, in_contractor_no);

ELSEIF in_query_type = "select" THEN

SELECT * FROM pv_collection;

end if$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pv_collection`
--

CREATE TABLE `pv_collection` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `pv_no` varchar(400) NOT NULL,
  `pv_date` date NOT NULL,
  `computer_pv_no` varchar(400) NOT NULL,
  `project_type` varchar(400) NOT NULL,
  `project_name` varchar(400) NOT NULL,
  `mda_name` varchar(400) NOT NULL,
  `contractor_name` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pv_collection`
--
ALTER TABLE `pv_collection`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pv_collection`
--
ALTER TABLE `pv_collection`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
