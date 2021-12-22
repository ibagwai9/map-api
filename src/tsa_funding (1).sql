-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 19, 2021 at 02:41 PM
-- Server version: 10.4.19-MariaDB
-- PHP Version: 8.0.7

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
-- Table structure for table `tsa_funding`
--

CREATE TABLE `tsa_funding` (
  `fund_date` date NOT NULL,
  `account_name` varchar(40) NOT NULL,
  `account_number` varchar(40) NOT NULL,
  `bank_name` varchar(40) NOT NULL,
  `sort_code` varchar(400) NOT NULL,
  `balance` float DEFAULT 0,
  `account_type` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tsa_funding`
--

INSERT INTO `tsa_funding` (`fund_date`, `account_name`, `account_number`, `bank_name`, `sort_code`, `balance`, `account_type`) VALUES
('2021-11-12', 'Finance', '12123', 'Zenith Bank', '', 935000, 'source'),
('2021-11-12', 'Admin', '6585', 'Jaiz', '', 195000, 'destination');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tsa_funding`
--
ALTER TABLE `tsa_funding`
  ADD PRIMARY KEY (`account_number`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


--
-- Table structure for table `funding_entires`
--

CREATE TABLE `funding_entires` (
  `fund_date` date NOT NULL,
  `Account_number` varchar(30) CHARACTER SET latin1 NOT NULL,
  `dr` float NOT NULL,
  `cr` float NOT NULL,
  `reference_number` int(20) NOT NULL,
  `Serial_number` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `funding_entires`
--

INSERT INTO `funding_entires` (`fund_date`, `Account_number`, `dr`, `cr`, `reference_number`, `Serial_number`) VALUES
('2021-11-12', '12123', 65000, 0, 346, 3),
('2021-11-12', '6585', 0, 65000, 346, 4),
('2021-11-12', '12123', 65000, 0, 346, 5),
('2021-11-12', '6585', 0, 130000, 346, 6),
('2021-11-12', '12123', 65000, 0, 346, 7),
('2021-11-12', '6585', 0, 65000, 346, 8);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `funding_entires`
--
ALTER TABLE `funding_entires`
  ADD PRIMARY KEY (`Serial_number`),
  ADD KEY `fund_fk` (`Account_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `funding_entires`
--
ALTER TABLE `funding_entires`
  MODIFY `Serial_number` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `funding_entires`
--
ALTER TABLE `funding_entires`
  ADD CONSTRAINT `fund_fk` FOREIGN KEY (`Account_number`) REFERENCES `tsa_funding` (`account_number`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


---***************************TSA Funding procedure*********************************************
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `tsa_funding`(IN `in_fund_date` DATE, IN `in_mda_source_account` VARCHAR(60), IN `in_mda_account_no` VARCHAR(40), IN `in_mda_bank_name` VARCHAR(40), IN `in_mda_sort_code` VARCHAR(20), IN `in_treasury_account_name` VARCHAR(60), IN `in_treasury_account_no` VARCHAR(40), IN `in_treasury_bank_name` VARCHAR(60), IN `in_amount` FLOAT(10), IN `in_reference_number` VARCHAR(10))
begin
declare new_balance, balance_data,new_balance1, balance_data1 float(10);

select ifnull(balance,0) into balance_data from tsa_funding where account_number = in_mda_account_no and account_type='source';

if balance_data is not null then

set new_balance =balance_data- in_amount;

update tsa_funding set balance=new_balance where account_number = in_mda_account_no and account_type='source';
	
insert into funding_entires(fund_date,	Account_number,	dr,	cr,	reference_number)
values (in_fund_date,in_mda_account_no,in_amount,0,in_reference_number);
else 

insert into tsa_funding(fund_date,account_name,account_number,bank_name,sort_code,	balance	,account_type)
values(in_fund_date,in_mda_source_account,in_mda_account_no,in_mda_bank_name,'',	in_amount,'source');

insert into funding_entires(fund_date,	Account_number,	dr,	cr,	reference_number)
values (in_fund_date,in_mda_account_no,in_amount,0,in_reference_number);

end if;


select ifnull(balance,0) into balance_data1 from tsa_funding where account_number = in_treasury_account_no and account_type='destination';

if balance_data1 is not null then

set new_balance1 =balance_data1+ in_amount;

update tsa_funding set balance=new_balance1 where account_number = in_treasury_account_no and account_type='destination';

insert into funding_entires(fund_date,	Account_number,	dr,	cr,	reference_number)
values (in_fund_date,in_treasury_account_no,0,in_amount,in_reference_number);

else 
insert into tsa_funding(fund_date,account_name,account_number,bank_name,sort_code,	balance	,account_type)

values(in_fund_date,in_treasury_account_name,in_treasury_account_no,in_treasury_bank_name,'',	in_amount,'destination');

insert into funding_entires(fund_date,	Account_number,	dr,	cr,	reference_number)
values (in_fund_date,in_treasury_account_no,0,in_amount,in_reference_number);


end if;

end$$
DELIMITER ;

----**************************sample procedure call*********************************************
call `tsa_funding`('2021-11-12', 'Finance', '12123', 'Zenith Bank', '65005', 'Admin', '6585', 'Jaiz',65000,'346');

---**************************tables used*******************************************************

---1. tsa_funding :  this table holds the details balances of each account(account_number is the primary key)
---2. funding_entires : this table holds transaction histories of all tranfer made to TSA account (account_number is the foriegn key referencing tsa_funding )
