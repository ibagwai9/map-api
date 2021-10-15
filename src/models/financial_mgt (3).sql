-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 14, 2021 at 07:49 PM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `batch_list` (IN `in_query_type` VARCHAR(20), IN `in_batch_no` VARCHAR(20))  NO SQL
if in_query_type = "select" THEN
SELECT date,count(description) 'no_of_payments',sum(amount) 'total_amount',batch_no 'batch_number' FROM `payment_schedule` GROUP by date,batch_no;

ELSEIF in_query_type = "select_by_batch_no" THEN
SELECT * FROM `payment_schedule` WHERE batch_no = in_batch_no;

ELSEIF in_query_type = "select_treasury" THEN
SELECT * FROM payment_schedule WHERE batch_no = in_batch_no;

END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `budget_summary` (IN `in_query_type` VARCHAR(400), IN `in_mda_code` VARCHAR(400), IN `in_mda_name` VARCHAR(400), IN `in_economic_code` VARCHAR(400), IN `in_budget_description` VARCHAR(400), IN `in_budget_amount` VARCHAR(400))  NO SQL
IF in_query_type = "insert" THEN

INSERT INTO budget_summary (mda_code, mda_name, economic_code, budget_description, budget_amount) VALUES (mda_code, mda_name, in_economic_code, in_budget_description, in_budget_amount);

ELSEIF in_query_type = "list" THEN
SELECT * FROM budget_summary;

ELSEIF in_query_type = "select_distinct" THEN
SELECT * FROM budget_summary WHERE mda_code = in_mda_code AND economic_code = in_economic_code;

END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cheque_details` (IN `date` VARCHAR(20), IN `batch_number` VARCHAR(20), IN `cheque_number` INT(20), IN `query_type` VARCHAR(20))  NO SQL
BEGIN
IF query_type='INSERT' THEN
INSERT INTO cheque_details(date,batch_number,cheque_number)
VALUES(in_date,in_batch_number,in_cheque_number);

ELSEIF  query_type='UPDATE' THEN
UPDATE cheque_details SET date=in_date,batch_number=in_batch_number,cheque_number=in_cheque_number WHERE cheque_number=in_cheque_number;

ELSEIF query_type='DELETE' THEN
DELETE FROM cheque_details WHERE cheque_number=in_cheque_number;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `contractor_details` (IN `in_query_type` VARCHAR(400), IN `in_contractor_name` VARCHAR(400), IN `in_contractor_phone_no` VARCHAR(400), IN `in_contractor_address` VARCHAR(400), IN `in_contractor_email` VARCHAR(400), IN `in_contractor_tin_no` VARCHAR(400))  NO SQL
IF in_query_type = "insert" THEN

INSERT INTO contractor_details (contractor_no, contractor_name, contractor_phone_no, contractor_address, contractor_email, contractor_tin_no) 

VALUES (in_contractor_no, in_contractor_name, in_contractor_phone_no, in_contractor_address, in_contractor_email, in_contractor_tin_no);

ELSEIF in_query_type = "select" THEN

SELECT * FROM contractor_details;

end if$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mda_bank_details` (IN `in_account_name` VARCHAR(20), IN `in_account_number` VARCHAR(20), IN `in_sort_code` VARCHAR(20), IN `in_bank_name` VARCHAR(20), IN `in_query_type` VARCHAR(20), IN `in_id` VARCHAR(20))  NO SQL
BEGIN 
IF in_query_type='INSERT' THEN
INSERT INTO mda_bank_details(account_name,account_number,sort_code,bank_name)
VALUES(in_account_name,in_account_number,in_sort_code,in_bank_name);

ELSEIF in_query_type = "select" THEN
SELECT id, account_name, account_number, sort_code, bank_name, account_type,  concat (account_name, " (",  account_number, ")") as account_info FROM mda_bank_details;

ELSEIF in_query_type = "select_by_id" THEN
SELECT * FROM mda_bank_details WHERE in_id = id;

ELSEIF in_query_type='UPDATE' THEN
UPDATE mda_bank_details SET account_number=in_account_number,
account_name=in_account_name,sort_code=in_sort_code,bank_name=in_bank_name WHERE account_number=in_account_number;

ELSEIF  in_query_type='DELETE' THEN
DELETE FROM mda_bank_details WHERE account_number=in_account_number;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mfo1` (IN `in_parent_code` INT(10), IN `in_child_code` VARCHAR(10), IN `in_description` VARCHAR(200), IN `in_amount` VARCHAR(20), IN `query_type` VARCHAR(50))  NO SQL
IF query_type='INSERT' THEN
INSERT INTO table_a(parent_code, 
child_code, 
description, 
amount) 
VALUES(in_parent_code, 
in_child_code, 
in_description, 
in_amount);
ELSEIF  query_type='UPDATE' THEN 
UPDATE table_a SET parent_code=in_parent_code, 
child_code=in_child_code, 
description=in_description, 
amount=in_amount WHERE parent_code=in_parent_code;
ELSEIF  query_type='DELETE' THEN 
DELETE FROM table_a WHERE parent_code=in_parent_code;
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mfo2` (IN `in_date` DATE, IN `in_parent_code` VARCHAR(10), IN `in_child_code` VARCHAR(10), IN `in_description` VARCHAR(200), IN `in_credit` VARCHAR(20), IN `in_debit` VARCHAR(20), IN `in_entered_by` VARCHAR(15), IN `query_type` VARCHAR(50), IN `in_id` VARCHAR(50))  NO SQL
BEGIN
IF query_type='INSERT' THEN
INSERT INTO table_b(date, parent_code, child_code, description, credit, debit, entered_by)
VALUES(in_date,in_parent_code,in_child_code,in_description,in_credit,in_debit,in_entered_by);

ELSEIF  query_type='UPDATE' THEN 
UPDATE table_b SET date=in_date,parent_code=in_parent_code,child_code=in_child_code,description=in_description,credit=in_credit,debit=in_debit,entered_by=in_entered_by
WHERE id=in_id;

ELSEIF query_type='DELETE' THEN
DELETE FROM table_b WHERE id=in_id;
END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `payment_schedule` (IN `in_query_type` VARCHAR(400), IN `in_date` DATE, IN `in_batch_no` VARCHAR(400), IN `in_treasury_account_name` VARCHAR(400), IN `in_treasury_account_no` VARCHAR(400), IN `in_treasury_bank_name` VARCHAR(400), IN `in_mda_account_name` VARCHAR(400), IN `in_mda_account_no` VARCHAR(400), IN `in_mda_bank_name` VARCHAR(400), IN `in_mda_acct_sort_code` VARCHAR(400), IN `in_mda_code` VARCHAR(400), IN `in_mda_name` VARCHAR(400), IN `in_mda_description` VARCHAR(400), IN `in_mda_budget_balance` VARCHAR(400), IN `in_mda_economic_code` VARCHAR(400), IN `in_amount` VARCHAR(400), IN `in_description` VARCHAR(400), IN `in_attachment` VARCHAR(400), IN `in_treasury_source_account` VARCHAR(400))  NO SQL
IF in_query_type = "insert" THEN

INSERT INTO payment_schedule(           
    date,
    batch_no,
    treasury_source_account,
    treasury_account_name,
    treasury_account_no,
    treasury_bank_name,
    mda_account_name,
    mda_account_no,
    mda_bank_name,
    mda_acct_sort_code,
    mda_code,
    mda_name,
    mda_description,
    mda_budget_balance,
    mda_economic_code,
    amount,
    description,
    attachment   
) 

VALUES (           
    in_date,
    in_batch_no,
    in_treasury_source_account,
    in_treasury_account_name,
    in_treasury_account_no,
    in_treasury_bank_name,
    in_mda_account_name,
    in_mda_account_no,
    in_mda_bank_name,
    in_mda_acct_sort_code,
    in_mda_code,
    in_mda_name,
    in_mda_description,
    in_mda_budget_balance,
    in_mda_economic_code,
    in_amount,
    in_description,
    in_attachment   
);

ELSEIF in_query_type = "select" THEN

SELECT * FROM payment_schedule;

end if$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `post_budget` (IN `in_query_type` VARCHAR(400), IN `in_date` DATE, IN `in_budget_code` VARCHAR(400), IN `in_remarks` VARCHAR(400), IN `in_budget_amount` VARCHAR(400))  NO SQL
BEGIN
IF in_query_type='insert' THEN
INSERT INTO post_budget(date,
    budget_code,
    remarks,
    budget_amount) VALUES(
     in_date,
    in_budget_code,
    in_remarks,
    in_budget_amount);
    
ELSEIF in_query_type='select' THEN
SELECT * FROM post_budget;

END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pv_collection` (IN `in_query_type` VARCHAR(400), IN `in_date` DATE, IN `in_pv_no` VARCHAR(400), IN `in_pv_date` VARCHAR(400), IN `in_computer_pv_no` VARCHAR(400), IN `in_project_type` VARCHAR(400), IN `in_project_name` VARCHAR(400), IN `in_mda_name` VARCHAR(400), IN `in_contractor_no` VARCHAR(400), IN `in_bank` VARCHAR(400), IN `in_sort_code` VARCHAR(400), IN `in_amount` VARCHAR(400), IN `in_tin` VARCHAR(400), IN `in_account_no` VARCHAR(400), IN `in_project_description` VARCHAR(400), IN `in_tax_details` VARCHAR(400))  NO SQL
IF in_query_type = "insert" THEN

INSERT INTO pv_collection (date, pv_no, pv_date, computer_pv_no, project_type, project_name, mda_name, contractor_no,  bank,
        sort_code,
        amount,
        tin,
        account_no,
        project_description,
        tax_details)
   
        

VALUES (in_date, in_pv_no, in_pv_date, in_computer_pv_no, in_project_type, in_project_name, in_mda_name, in_contractor_no,  in_bank,
        in_sort_code,
        in_amount,
        in_tin,
        in_account_no,
       in_project_description,
        in_tax_details);

ELSEIF in_query_type = "select" THEN

SELECT * FROM pv_collection;

end if$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_budget` (IN `in_mda_name` VARCHAR(20), IN `in_mda_parent_code` VARCHAR(20), IN `in_mda_child_code` VARCHAR(20), IN `in_description` VARCHAR(20), IN `in_amount` VARCHAR(20), IN `in_remarks` VARCHAR(20), IN `query_type` VARCHAR(50), IN `in_id` VARCHAR(400), IN `in_post_budget_amount` VARCHAR(400))  NO SQL
BEGIN
IF query_type='INSERT' THEN
INSERT INTO update_budget(mda_name,mda_parent_code,mda_child_code,description,amount,remarks) VALUES(in_mda_name,in_mda_parent_code,in_mda_child_code,in_description,in_amount,in_remarks);

ELSEIF  query_type='UPDATE' THEN
UPDATE update_budget SET mda_name=in_mda_name,mda_parent_code=in_mda_parent_code,description=in_description,amount=in_amount + in_post_budget_amount,remarks=in_remarks WHERE mda_child_code=in_mda_child_code;

ELSEIF query_type='DELETE' THEN
DELETE FROM update_budget WHERE in_mda_child_code=mda_child_code;

ELSEIF query_type = "select_all_child_code1" THEN
SELECT * FROM update_budget; 

ELSEIF query_type = "tree" THEN
SELECT  mda_parent_code as  subhead, mda_child_code as  title, description, amount, id from update_budget;

ELSEIF query_type = "select_by_tree" THEN
SELECT MAX(mda_child_code) + 1 as child_code FROM update_budget WHERE mda_parent_code = in_mda_parent_code;

ELSEIF query_type = "select_all_child_code" THEN 
SELECT mda_child_code, description, amount, mda_parent_code,  concat (description, "(", mda_child_code, ")") as budget FROM update_budget;

END IF; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `budget_summary`
--

CREATE TABLE `budget_summary` (
  `id` int(11) NOT NULL,
  `mda_code` varchar(400) NOT NULL,
  `mda_name` varchar(400) NOT NULL,
  `economic_code` varchar(400) NOT NULL,
  `budget_description` varchar(400) NOT NULL,
  `budget_amount` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `budget_summary`
--

INSERT INTO `budget_summary` (`id`, `mda_code`, `mda_name`, `economic_code`, `budget_description`, `budget_amount`) VALUES
(1, '11100100100', ' Government House', '22021001', 'REFRESHMENT & MEALS', '500000'),
(2, '11100100101', ' Government House', '22021002', 'REFRESHMENT & MEALS', '500001'),
(3, '11100100102', ' Government House', '22021003', 'REFRESHMENT & MEALS', '500002'),
(4, '11100100103', ' Government House', '22021004', 'REFRESHMENT & MEALS', '500003'),
(5, '11100100104', ' Government House', '22021005', 'REFRESHMENT & MEALS', '500004'),
(6, '11100100105', ' Government House', '22021006', 'REFRESHMENT & MEALS', '500005'),
(7, '11100100106', ' Government House', '22021007', 'REFRESHMENT & MEALS', '500006'),
(8, '11100100107', ' Government House', '22021008', 'REFRESHMENT & MEALS', '500007'),
(9, '11100100108', ' Government House', '22021009', 'REFRESHMENT & MEALS', '500008'),
(10, '11100100109', ' Government House', '22021010', 'REFRESHMENT & MEALS', '500009'),
(11, '11100100100', ' Government House', '22021001', 'REFRESHMENT & MEALS', '500000'),
(12, '11100100101', ' Government House', '22021002', 'REFRESHMENT & MEALS', '500001'),
(13, '11100100102', ' Government House', '22021003', 'REFRESHMENT & MEALS', '500002'),
(14, '11100100103', ' Government House', '22021004', 'REFRESHMENT & MEALS', '500003'),
(15, '11100100104', ' Government House', '22021005', 'REFRESHMENT & MEALS', '500004');

-- --------------------------------------------------------

--
-- Table structure for table `cheque_details`
--

CREATE TABLE `cheque_details` (
  `date` varchar(20) NOT NULL,
  `batch_number` varchar(20) NOT NULL,
  `cheque_number` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `contractor_details`
--

CREATE TABLE `contractor_details` (
  `id` int(11) NOT NULL,
  `contractor_no` varchar(400) NOT NULL,
  `contractor_name` varchar(400) NOT NULL,
  `contractor_phone` varchar(400) NOT NULL,
  `contractor_address` varchar(400) NOT NULL,
  `contractor_email` varchar(400) NOT NULL,
  `contractor_tin_no` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mda_bank_details`
--

CREATE TABLE `mda_bank_details` (
  `id` int(11) NOT NULL,
  `account_name` varchar(20) NOT NULL,
  `account_description` varchar(20) NOT NULL,
  `account_number` varchar(20) NOT NULL,
  `sort_code` varchar(20) NOT NULL,
  `bank_name` varchar(20) NOT NULL,
  `account_type` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mda_bank_details`
--

INSERT INTO `mda_bank_details` (`id`, `account_name`, `account_description`, `account_number`, `sort_code`, `bank_name`, `account_type`) VALUES
(1, 'MDA', '', 'ACCOUNTS No.', 'SORT CODE', 'BANKS', ''),
(2, 'Government House', '', '5030025714', '70120211', 'Fidelity Bank Plc 11', ''),
(3, 'Kano University of T', '', '2031842857', '11121130', 'First Bank Acct Wudi', ''),
(4, 'Yusuf Maitama Sule U', '', '1013279375', '57120043', 'Zenith Bank Plc Unit', ''),
(5, 'Deputy Gov Office', '', '5030066953', '70120211', 'FIDELITY BANK', ''),
(6, 'Ministry of Land & P', '', '1003268624', '33120012', 'U. B. A.post office ', 'mda_source_account'),
(7, 'Ministry of Planning', '', '873998012', '85122026', 'First  City Monument', ''),
(8, 'Secretary to the Sta', '', '115201126', '82120555', 'Guaranty Trust Bank ', 'mda_source_account'),
(9, 'Special Services Dir', '', '5147937014', '70120211', 'FCMB BOMPAI ROAD,KAN', ''),
(10, 'Ministry of Educatio', '', '1010446732', '57120014', 'Zenith bank Murtala ', ''),
(11, 'Ministry for Local G', '', '2001551613', '11122155', 'First Bank, Lagos St', ''),
(12, 'Office of the Audit ', '', '2004262028', '11123727', 'First Bank Zoo Road', 'treasury_source_account'),
(13, 'Local Government Aud', '', '2005875492', '11123727', 'First Bank Zoo Road', 'treasury_source_account'),
(14, 'Civil Service Commis', '', '5210165', '215124014', 'Unity Bank Plc, Zoo ', ''),
(15, 'Ministry of Women Af', '', '5030071508', '70120350', 'fidelity bank plc ib', ''),
(16, 'Ministry of Water Re', '', '5238093', '215123976', 'Unity Bank Plc Zoo R', ''),
(17, 'REPA Directorate', '', '14219931', '215122414', 'Unity Bank Plc, Lago', ''),
(18, 'Office of the Head o', '', '1012641737', '57120108', 'Zenith Bank Plc Zoo ', ''),
(19, 'Kano State Fire Serv', '', '1014928405', '57120056', 'zenith bank naibawa ', ''),
(20, 'Kano State Afforesta', '', '39942230', '44122135', 'Access Bank Plc 3B B', ''),
(21, 'Kano State Agency fo', '', '1014526502', '57120056', 'Zenith Bank Plc,Hoto', ''),
(22, 'Kano State  Library ', '', '20009792', '58123010', 'GTBank  M/Muhd Way ', ''),
(23, 'SUBEB KANO EXPENDITU', '', '1014762120', '57120014', 'ZENITH BANK  PLC', ''),
(24, 'Kano Informatics Ins', '', '9589248', '232120033', 'Sterling Bank Plc Un', ''),
(25, 'Public Complaints & ', '', '1014816140', '57120014', 'Zenith Bank Murtala ', ''),
(26, 'Public Account Commi', '', '36431831', '32123968', 'Union Bank, Zoo Road', ''),
(27, 'Societal re orientat', '', '5210440', '215124014', 'Unity Bank Plc Zoo R', ''),
(28, 'Law Reform  Commissi', '', '1076933019', '85122026', 'FCMB. Murtala Mohamm', ''),
(29, 'Project & Monitoring', '', '2004900140', '11121130', 'First Bank Lagos Str', ''),
(30, 'Kano State Hisbah Bo', '', '25465196', '215124014', 'Unity Bank Plc Kwari', ''),
(31, 'Shari ah Commission ', '', '1001149673', '82120092', 'KeystoneBank Post Of', ''),
(32, 'State Agency for Con', '', '2023209479', '11121130', 'First Bank Plc', ''),
(33, 'Kano Geographic Info', '', '32300412', '63120079', 'Diamond Bank Plc', ''),
(34, 'KNARDA', '', '1010531410', '57120014', 'Zenith Bank plc M. M', ''),
(35, 'K State Tourism Boar', '', '1003686994', '33122696', 'United Bank for Afri', ''),
(36, 'Executive Council Di', '', '1750011031', '76121845', 'SKYE Bank Plc M. Muh', ''),
(37, 'Ministry of Finance', '', '6499239', '215122430', 'Unity Bank Plc, Shar', ''),
(38, 'Kano Development Jou', '', '2025297647', '11121130', 'First Bank Plc', ''),
(39, 'Kano state institute', '', '1013450738', '57120098', 'Zenith Bank Plc, Na\'', ''),
(40, 'Refuse Mngt.  and Sa', '', '5193523', '215122414', 'Unity Bank Bello Roa', ''),
(41, 'Kano State Independe', '', '237585807', '58123023', 'GTB ZARIA RD', ''),
(42, 'Road Traffic Dept Mi', '', '165909795', '58123023', 'GTBank  Zaria Rod  ', ''),
(43, 'Kano State Computer ', '', '871724015', '214121830', 'FCMB Murtala M/Way', ''),
(44, 'kano film academy', '', '2027550045', '11121130', 'first bank plc main ', ''),
(45, 'kano State Ist. Of L', '', '26989551', '11121130', 'Diamod Bank M. M. Wa', ''),
(46, 'KANO POULTRY INSTITU', '', '30274553', '63121489', 'Diamod Bank FRANCE R', ''),
(47, 'kano State C.R.C.', '', '19816548', '11121130', 'Unity Bank Plc, Bell', ''),
(48, 'kano state private a', '', '1014299503', '57120014', 'zenith bank mmway', ''),
(49, 'GTC Rogo', '', '22830146', '215124564', 'Unity Bank Plc', ''),
(50, 'GTC Albasu', '', '2024599708', '11121130', 'First Bank Plc', ''),
(51, 'GTC Dambatta II', '', '51611429', '63120587', 'Diamond bank Plc', ''),
(52, 'GTC Dawakin Tofa', '', '22690661', '216124250', 'Unity Bank Plc', ''),
(53, 'GTC Gabasawa', '', '1006247653', '82120995', 'Keystone Bank Plc', ''),
(54, 'GTC Gwale', '', '1017712971', '33120669', 'United Bank for Afri', ''),
(55, 'GTC Karaye', '', '22740009', '215124564', 'Unity Bank Plc', ''),
(56, 'GTC Kunchi', '', '2024233107', '11127341', 'First Bank Plc', ''),
(57, 'GTC Minjibir', '', '1766790834', '76124240', 'SKYE Bank Plc', ''),
(58, 'GTC Nassarawa', '', '8355617', '221150014', 'Stanbic IBTC Plc', ''),
(59, 'GTC Rano', '', '1017763351', '33121367', 'United Bank for Afri', ''),
(60, 'GTC Takai', '', '1006179497', '82120911', 'Keystone Bank Plc', ''),
(61, 'GTC Warawa', '', '8683228', '221150014', 'Stanbic IBTC Plc', ''),
(62, 'GTC Bichi', '', '688998989', '44121136', 'Access Bank Plc', ''),
(63, 'GTC Wudil', '', '2024493820', '11127875', 'First Bank Plc', ''),
(64, 'GTC Bagwai', '', '14122687', '221150014', 'Stanbic IBTC Plc', ''),
(65, 'GTC Gaya', '', '3078773801', '11150000', 'First Bank Plc', ''),
(66, 'GTC Ungogo II', '', '60931862', '60931662', 'Diamond Bank Plc', ''),
(67, 'GTC Kabo', '', '51469572', '63120587', 'Diamond bank Plc', ''),
(68, 'GTC Fagge', '', '8659470', '221150014', 'Stanbic IBTC Plc', ''),
(69, 'GTC Sani Abacha', '', '9223946', '221150014', 'Stanbic IBTC Bank', ''),
(70, 'GTC Dadin kowa', '', '4060011502', '76121845', 'SKYE Bank Plc ', ''),
(71, 'GTC Sumaila', '', '25305146', '215123976', 'Unity Bank ', ''),
(72, 'GTC Gani', '', '36475404', '32124530', 'Union Bank', ''),
(73, 'GTC Dawakin Kudu', '', '22713009', '215124001', 'Unity Bank Plc', ''),
(74, 'Mal.Shehu Minjibir B', '', '11484784', '221150014', 'Stanbic IBTC Bank Pl', ''),
(75, 'School of Nursing Ma', '', '2029132999', '11150000', 'First Bank Plc,Fagge', ''),
(76, 'Sch. Of Basic Midwif', '', '1637617011', '214122130', 'FCMB', ''),
(77, 'Sch. Of Nursing Kano', '', '2004256043', '11123727', 'First Bank of Nigeri', ''),
(78, 'Sch. Of Health Techn', '', '34241436', '32127980', 'Union Bank of Nigeri', ''),
(79, 'Sch. Of Anesthesia', '', '1137338', '301080000', 'Jaiz Bank Plc', ''),
(80, 'College of Nursing &', '', '24009882', '232120020', 'Sterling Bank Plc', ''),
(81, 'Sch. Of Basic Midwif', '', '1767900018', '214122130', 'FCMB', ''),
(82, 'School of Basic Midw', '', '2697045019', '214122130', 'FCMB', ''),
(83, 'KNUPDA', '', '19955039', '58123010', 'Guaranty Trust Bank ', ''),
(84, 'KAROTA', '', '2021809284', '11122155', 'First Bank Plc Lagos', ''),
(85, 'Kano Investment Prom', '', '1014807638', '57120056', 'Zenith Bank Hotoro B', ''),
(86, 'Kano Enterprenuershi', '', '2023845996', '11122155', 'First bank Dawanau ', ''),
(87, 'Kano State Relief & ', '', '1002818501', '82120092', 'KeystoneBank Bello R', ''),
(88, 'Ministry of Environm', '', '1010308917', '57120014', 'Zenith Bank Murtala ', ''),
(89, 'Kano State Censorshi', '', '4090740072', '14120332', 'SKYE Bank Plc M. Muh', ''),
(90, 'Protocol Directorate', '', '5260265018', '214122130', 'FCMB', ''),
(91, 'Ministry of Health', '', '5843531', '232120046', 'Sterling Bank Plc Ni', ''),
(92, ' Research and Docume', '', '71802979', '63120079', 'Diamond bank plc', ''),
(93, 'Ministry of Works', '', '1010272667', '57120014', 'Zenith Bank Murtala ', ''),
(94, 'kano state qur\'anic ', '', '2027745324', '11121130', 'first bank bank road', ''),
(95, 'Kano State Farm Mech', '', '25978675', '232120020', 'Sterling Bank plc, s', ''),
(96, 'kano state Driving i', '', '2031970417', '11121130', 'First Bank plc,zoo R', ''),
(97, 'Servicom Directorate', '', '1019287242', '33122272', 'U.B.A. Post Office R', ''),
(98, 'Ministry of Agricult', '', '764601312', '11121130', 'Access Bank Bello Ro', ''),
(99, 'Primary Health Care ', '', '1013093993', '57120014', 'Zenith Bank Plc, Na’', ''),
(100, 'Guidance & Counselin', '', '1001464004', '82120092', 'KeystoneBank Post Of', ''),
(101, 'Special Duties  Dire', '', '1012811952', '57120098', 'Zenith Bank Plc Naib', ''),
(102, 'Sustainable Kano Pro', '', '20025729', '58123010', 'Guaranty Trust Bank ', ''),
(103, 'Youth Dir.For Econ. ', '', '109846434', '58123010', 'GTB M/MUHAMMAD WAY', ''),
(104, 'kano State Bureau of', '', '56159942', '11121130', 'Diamod Bank Plc, Ban', ''),
(105, 'Directorate of Rural', '', '1006773541', '82120092', 'Keystone Bank Post o', ''),
(106, 'Ministry of Justice', '', '21830047', '32103955', 'Union Bank Plc Bank ', ''),
(107, 'Kano Fisheries Insti', '', '18671547', '232120062', 'Sterling Bank Plc  B', ''),
(108, 'School of Health Tec', '', '40353109', '32127980', 'Union Bank Plc', ''),
(109, 'K.S. Scholarship Boa', '', '5198597', '215122414', 'Unity Bank Plc, Bell', ''),
(110, 'Hospital Management ', '', '1016128683', '33122272', 'UBA 15B Post Office ', ''),
(111, 'Ministry of Informat', '', '5052569016', '214121830', 'FCMB', ''),
(112, 'RUWASA', '', '1000915233', '33122696', 'U. B. A. Bello Road', ''),
(113, 'Judicial Service Com', '', '4916489', '232120033', 'Sterling Bank M.M. W', ''),
(114, 'Kano Hospitaliy and ', '', '26150450', '11121130', 'Diamond Bank Plc, M.', ''),
(115, 'Ministry of Commerce', '', '2909214', '232120046', 'Sterling Bank Plc Ni', ''),
(116, 'GTC Makoda', '', '2024327905', '11127341', 'First Bank Plc', ''),
(117, 'GTC Gezawa', '', '1766790755', '76124240', 'SKYE Bank Plc ', ''),
(118, 'GTC TOFA', '', '1015527245', '57120085', 'ZENITH BANK  PLC', ''),
(119, 'GTC TIGA', '', '1015541807', '5712085', 'ZENITH BANK  PLC', ''),
(120, 'Sport Council', '', '5185984', '215122414', 'Unity Bank Bello Roa', ''),
(121, 'School of Basic Midw', '', '5101000017', '11121130', 'FCMB Bompai Road', ''),
(122, 'History & Culture B', '', '1004008180', '33122272', 'United Bank for Afri', ''),
(123, 'Drugs Management Age', '', '20070114', '58123010', 'Guaranty Trust Bank ', ''),
(124, 'Kano State Teachers ', '', '5230743', '215123976', 'Unity Bank Zoo Road', ''),
(125, 'Kano State Road Main', '', '2024887012', '11121130', 'First Bank Plc', ''),
(126, 'Zakkah Commission ', '', '2634194', '232120075', 'Sterling Bank Murtal', ''),
(127, 'Kano State Zoologica', '', '1019952340', '33122272', 'UBA SHARADA BRANCH', ''),
(128, '', '', '', '', '', ''),
(129, '', '', '', '', '', ''),
(130, '', '', '', '', '', ''),
(131, '', '', '', '', '', ''),
(132, '', '', '', '', '', ''),
(133, '', '', '', '', '', ''),
(134, '', '', '', '', '', ''),
(135, '', '', '', '', '', ''),
(136, '', '', '', '', '', ''),
(137, '', '', '', '', '', ''),
(138, '', '', '', '', '', ''),
(139, '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `payment_schedule`
--

CREATE TABLE `payment_schedule` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `payment_type` varchar(400) NOT NULL,
  `description` varchar(400) NOT NULL,
  `amount` varchar(400) NOT NULL,
  `batch_no` varchar(400) NOT NULL,
  `treasury_source_account` varchar(400) NOT NULL,
  `treasury_account_name` varchar(400) NOT NULL,
  `treasury_account_no` varchar(400) NOT NULL,
  `treasury_bank_name` varchar(400) NOT NULL,
  `mda_account_name` varchar(400) NOT NULL,
  `mda_account_no` varchar(400) NOT NULL,
  `mda_bank_name` varchar(400) NOT NULL,
  `mda_acct_sort_code` varchar(400) NOT NULL,
  `mda_code` varchar(400) NOT NULL,
  `mda_name` varchar(400) NOT NULL,
  `mda_description` varchar(400) NOT NULL,
  `mda_budget_balance` varchar(400) NOT NULL,
  `mda_economic_code` varchar(400) NOT NULL,
  `attachment` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `payment_schedule`
--

INSERT INTO `payment_schedule` (`id`, `date`, `payment_type`, `description`, `amount`, `batch_no`, `treasury_source_account`, `treasury_account_name`, `treasury_account_no`, `treasury_bank_name`, `mda_account_name`, `mda_account_no`, `mda_bank_name`, `mda_acct_sort_code`, `mda_code`, `mda_name`, `mda_description`, `mda_budget_balance`, `mda_economic_code`, `attachment`) VALUES
(1, '2021-10-21', '', 'REFRESHMENT & MEALS', '2000', '10', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100102', '', '', '500002', '', ''),
(2, '2021-10-20', '', 'REFRESHMENT & MEALS', '70000', '11', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Secretary to the Sta', '115201126', 'Guaranty Trust Bank ', '', '11100100101', '', '', '500001', '', ''),
(3, '2021-10-20', '', 'REFRESHMENT & MEALS', '70000', '11', '', 'Local Government Aud', '2005875492', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100104', '', '', '500004', '', ''),
(4, '2021-10-20', '', 'REFRESHMENT & MEALS', '70000', '11', '', 'Local Government Aud', '2005875492', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100104', '', '', '500004', '', ''),
(5, '2021-10-20', '', 'REFRESHMENT & MEALS', '70000', '11', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Secretary to the Sta', '115201126', 'Guaranty Trust Bank ', '', '11100100101', '', '', '500001', '', ''),
(6, '2021-10-13', '', 'REFRESHMENT & MEALS', '7000', '200', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100101', '', '', '500001', '', ''),
(7, '2021-10-13', '', 'REFRESHMENT & MEALS', '7000', '200', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100101', '', '', '500001', '', ''),
(8, '2021-10-13', '', 'REFRESHMENT & MEALS', '7000', '200', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100101', '', '', '500001', '', ''),
(9, '2021-10-13', '', 'REFRESHMENT & MEALS', '7000', '200', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100101', '', '', '500001', '', ''),
(10, '2021-10-13', '', 'REFRESHMENT & MEALS', '7000', '200', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100101', '', '', '500001', '', ''),
(11, '0000-00-00', '', 'REFRESHMENT & MEALS', '', '', '', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '', '11100100102', '', '', '500002', '', ''),
(12, '0000-00-00', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),
(13, '2021-10-21', '', 'REFRESHMENT & MEALS', '2000', '', 'Office of the Audit  (2004262028)', 'Office of the Audit ', '2004262028', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '33120012', '11100100100', '', '', '500000', '22021001', 'klnkl'),
(14, '2021-10-15', '', 'REFRESHMENT & MEALS', '8000', '2002', 'Local Government Aud (2005875492)', 'Local Government Aud', '2005875492', 'First Bank Zoo Road', 'Ministry of Land & P', '1003268624', 'U. B. A.post office ', '33120012', '11100100100', '', '', '500000', '22021001', ''),
(15, '0000-00-00', '', 'REFRESHMENT & MEALS', '5000', '', '', '', '', '', 'Secretary to the Sta', '115201126', 'Guaranty Trust Bank ', '82120555', '11100100101', '', '', '500001', '22021002', '');

-- --------------------------------------------------------

--
-- Table structure for table `post_budget`
--

CREATE TABLE `post_budget` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `budget_amount` varchar(400) NOT NULL,
  `budget_code` varchar(400) NOT NULL,
  `remarks` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `post_budget`
--

INSERT INTO `post_budget` (`id`, `date`, `budget_amount`, `budget_code`, `remarks`) VALUES
(1, '2021-09-23', 'njknjk', 'mnjnnjw', 'kjiojeoe'),
(2, '2021-09-23', 'njknjk', 'mnjnnjw', 'kjiojeoe'),
(3, '2021-10-02', '100000', '3000', 'Good'),
(4, '0000-00-00', '2000', '2000', 'ok');

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
  `contractor_name` varchar(400) NOT NULL,
  `contractor_no` varchar(400) NOT NULL,
  `bank` varchar(400) NOT NULL,
  `sort_code` varchar(400) NOT NULL,
  `amount` varchar(400) NOT NULL,
  `tin` varchar(400) NOT NULL,
  `account_no` varchar(400) NOT NULL,
  `tax_type` varchar(400) NOT NULL,
  `project_description` varchar(400) NOT NULL,
  `tax_details` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pv_collection`
--

INSERT INTO `pv_collection` (`id`, `date`, `pv_no`, `pv_date`, `computer_pv_no`, `project_type`, `project_name`, `mda_name`, `contractor_name`, `contractor_no`, `bank`, `sort_code`, `amount`, `tin`, `account_no`, `tax_type`, `project_description`, `tax_details`) VALUES
(1, '0000-00-00', '', '0000-00-00', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),
(2, '0000-00-00', '', '0000-00-00', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),
(3, '2021-09-17', 'klkkl', '2021-09-02', '', '', '', '1', '', '', '', '', '', '', '', '', '', ''),
(4, '2021-09-17', 'jkhak', '2021-09-10', '', 'option1', '', '2', '', '', '', '', '', '', '', '', '', ''),
(5, '2021-09-16', 'kbjj', '2021-09-15', '', 'option2', '', '1', '', '', 'option2', 'iioi', '77', 'jlnklnjl', 'ljklkk', '', 'nklnkl', 'Compute'),
(6, '0000-00-00', '', '0000-00-00', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),
(7, '0000-00-00', '', '0000-00-00', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),
(8, '2021-10-08', 'jioj', '2021-12-01', '', '', '', '1', '', '', '', 'njnl', '1', '8989', '', '', 'kj', 'Compute'),
(9, '2021-10-08', 'jioj', '2021-12-01', '', '', '', '1', '', '', '', 'njnl', '1', '8989', '', '', 'kj', 'Compute');

-- --------------------------------------------------------

--
-- Table structure for table `update_budget`
--

CREATE TABLE `update_budget` (
  `id` int(11) NOT NULL,
  `mda_name` varchar(20) NOT NULL,
  `mda_parent_code` varchar(20) NOT NULL,
  `mda_child_code` varchar(20) NOT NULL,
  `description` varchar(20) NOT NULL,
  `amount` varchar(20) NOT NULL,
  `remarks` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `update_budget`
--

INSERT INTO `update_budget` (`id`, `mda_name`, `mda_parent_code`, `mda_child_code`, `description`, `amount`, `remarks`) VALUES
(1, '', '', '1000', 'Kitchen', '2000', ''),
(7, '', '', '3000', 'honda washing 3', '1297', 'some other'),
(9, '', '', '2000', 'Feeding', '5000', ''),
(10, '', '2000', '2001', 'Baby Feeds', '500', ''),
(11, '', '', '4000', 'Toiletries', '6000', ''),
(12, '', '', '', '', '', ''),
(13, '', '', '', '', '', ''),
(14, '', '', '', '', '', ''),
(15, '', '', '', '', '', ''),
(16, '', '', '', '', '', ''),
(17, '', '', '', '', '', ''),
(18, '', '', '', '', '', ''),
(19, '', '', '', '', '', ''),
(20, '', '', '', '', '', ''),
(21, '', '', '', '', '', ''),
(22, '', '', '', '', '', ''),
(23, '', '', '', '', '', ''),
(24, '', '', '', '', '', ''),
(25, '', '', '', '', '', ''),
(26, '', '', '', '', '', ''),
(27, '', '', '', '', '', ''),
(28, '', '', '', '', '', ''),
(29, '', '', '', '', '', ''),
(30, '', '', '', '', '', ''),
(31, '', '', '', '', '', ''),
(32, '', '', '', '', '', ''),
(33, '', '', '', '', '', ''),
(34, '', '', '', '', '', ''),
(35, '', '', '', '', '', ''),
(36, '', '', '', '', '', ''),
(37, '', '', '', '', '', ''),
(38, '', '', '', '', '', ''),
(39, '', '', '', '', '', ''),
(40, '', '', '', '', '', ''),
(41, '', '', '', '', '', ''),
(42, '', '', '', '', '', ''),
(43, '', '', '', '', '', ''),
(44, '', '', '', '', '', ''),
(45, '', '', '', '', '', ''),
(46, '', '', '', '', '', ''),
(47, '', '', '', '', '', ''),
(48, '', '', '', '', '', ''),
(49, '', '', '', '', '', ''),
(50, '', '', '', '', '', ''),
(51, '', '', '', '', '', ''),
(52, '', '', '', '', '', ''),
(53, '', '', '', '', '', ''),
(54, '', '', '', '', '', ''),
(55, '', '', '', '', '', ''),
(56, '', '', '', '', '', ''),
(57, '', '', '', '', '', ''),
(58, '', '', '', '', '', ''),
(59, '', '', '', '', '', ''),
(60, '', '', '', '', '', ''),
(61, '', '', '', '', '', ''),
(62, '', '', '', '', '', ''),
(63, '', '', '', '', '', ''),
(64, '', '', '', '', '', ''),
(65, '', '', '', '', '', ''),
(66, '', '', '', '', '', ''),
(67, '', '', '', '', '', ''),
(68, '', '', '', '', '', ''),
(69, '', '', '', '', '', ''),
(70, '', '', '', '', '', ''),
(71, '', '', '', '', '', ''),
(72, '', '', '', '', '', ''),
(73, '', '', '', '', '', ''),
(74, '', '', '', '', '', ''),
(75, '', '', '', '', '', ''),
(76, '', '', '', '', '', ''),
(77, '', '', '', '', '', ''),
(78, '', '', '', '', '', ''),
(79, '', '', '', '', '', ''),
(80, '', '', '', '', '', ''),
(81, '', '', '', '', '', ''),
(82, '', '', '', '', '', ''),
(83, '', '', '', '', '', ''),
(84, '', '', '', '', '', ''),
(85, '', '', '', '', '', ''),
(86, '', '', '', '', '', ''),
(87, '', '', '', '', '', ''),
(88, '', '', '', '', '', ''),
(89, '', '', '', '', '', ''),
(90, '', '', '', '', '', ''),
(91, '', '', '', '', '', ''),
(92, '', '', '', '', '', ''),
(93, '', '', '', '', '', ''),
(94, '', '', '', '', '', ''),
(95, '', '', '', '', '', ''),
(96, '', '', '', '', '', ''),
(97, '', '', '', '', '', ''),
(98, '', '', '', '', '', ''),
(99, '', '', '', '', '', ''),
(100, '', '', '', '', '', ''),
(101, '', '', '', '', '', ''),
(102, '', '', '', '', '', ''),
(103, '', '', '', '', '', ''),
(104, '', '', '', '', '', ''),
(105, '', '', '', '', '', ''),
(106, '', '', '', '', '', ''),
(107, '', '', '', '', '', ''),
(108, '', '', '', '', '', ''),
(109, '', '', '', '', '', ''),
(110, '', '', '', '', '', ''),
(111, '', '', '', '', '', ''),
(112, '', '', '', '', '', ''),
(113, '', '', '', '', '', ''),
(114, '', '', '', '', '', ''),
(115, '', '', '', '', '', ''),
(116, '', '', '', '', '', ''),
(117, '', '', '', '', '', ''),
(118, '', '', '', '', '', ''),
(119, '', '', '', '', '', ''),
(120, '', '', '', '', '', ''),
(121, '', '', '', '', '', ''),
(122, '', '', '', '', '', ''),
(123, '', '', '', '', '', ''),
(124, '', '', '', '', '', ''),
(125, '', '', '', '', '', ''),
(126, '', '', '', '', '', ''),
(127, '', '', '', '', '', ''),
(128, '', '', '', '', '', ''),
(129, '', '', '', '', '', ''),
(130, '', '', '', '', '', ''),
(131, '', '', '', '', '', ''),
(132, '', '', '', '', '', ''),
(133, '', '', '', '', '', ''),
(134, '', '', '', '', '', ''),
(135, '', '', '', '', '', ''),
(136, '', '', '', '', '', ''),
(137, '', '', '', '', '', ''),
(138, '', '', '', '', '', ''),
(139, '', '', '', '', '', ''),
(140, '', '', '', '', '', ''),
(141, '', '', '', '', '', ''),
(142, '', '', '', '', '', ''),
(143, '', '', '', '', '', ''),
(144, '', '', '', '', '', ''),
(145, '', '', '', '', '', ''),
(146, '', '', '', '', '', ''),
(147, '', '', '', '', '', ''),
(148, '', '', '', '', '', ''),
(149, '', '', '', '', '', ''),
(150, '', '', '', '', '', ''),
(151, '', '', '', '', '', ''),
(152, '', '', '', '', '', ''),
(153, '', '', '', '', '', ''),
(154, '', '', '', '', '', ''),
(155, '', '', '', '', '', ''),
(156, '', '', '', '', '', ''),
(157, '', '', '', '', '', ''),
(158, '', '', '', '', '', ''),
(159, '', '', '', '', '', ''),
(160, '', '', '', '', '', ''),
(161, '', '', '', '', '', ''),
(162, '', '', '', '', '', ''),
(163, '', '', '', '', '', ''),
(164, '', '', '', '', '', ''),
(165, '', '', '', '', '', ''),
(166, '', '', '', '', '', ''),
(167, '', '', '', '', '', ''),
(168, '', '', '', '', '', ''),
(169, '', '', '', '', '', ''),
(170, '', '', '', '', '', ''),
(171, '', '', '', '', '', ''),
(172, '', '', '', '', '', ''),
(173, '', '', '', '', '', ''),
(174, '', '', '', '', '', ''),
(175, '', '', '', '', '', ''),
(176, '', '', '', '', '', ''),
(177, '', '', '', '', '', ''),
(178, '', '', '', '', '', ''),
(179, '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `firstname`, `lastname`, `username`, `email`, `password`, `role`, `createdAt`, `updatedAt`) VALUES
(1, 'Ishaq', 'Ibrahim', 'ibagwai', 'admin@gmail.com', '$2a$10$ZTXXTKxGv4zGo1nHHdx0WuQrc1XedITSi.q/3YEOc5Y2rnbusq/.S', 'admin', '2021-10-11 09:36:34', '2021-10-11 09:36:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `budget_summary`
--
ALTER TABLE `budget_summary`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `contractor_details`
--
ALTER TABLE `contractor_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mda_bank_details`
--
ALTER TABLE `mda_bank_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `payment_schedule`
--
ALTER TABLE `payment_schedule`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `post_budget`
--
ALTER TABLE `post_budget`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pv_collection`
--
ALTER TABLE `pv_collection`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `update_budget`
--
ALTER TABLE `update_budget`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `budget_summary`
--
ALTER TABLE `budget_summary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `contractor_details`
--
ALTER TABLE `contractor_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mda_bank_details`
--
ALTER TABLE `mda_bank_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;

--
-- AUTO_INCREMENT for table `payment_schedule`
--
ALTER TABLE `payment_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `post_budget`
--
ALTER TABLE `post_budget`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `pv_collection`
--
ALTER TABLE `pv_collection`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `update_budget`
--
ALTER TABLE `update_budget`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
