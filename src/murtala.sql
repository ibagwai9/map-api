CREATE TABLE `contact_us` ( `id` INT NOT NULL AUTO_INCREMENT , `fullname` VARCHAR(100) NULL DEFAULT NULL , `email` VARCHAR(60) NULL DEFAULT NULL , `message` VARCHAR(2000) NOT NULL , `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP , `inserted_by` VARCHAR(80) NULL DEFAULT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `contact_us`(IN `query_type` VARCHAR(50), IN `in_fullname` VARCHAR(100), IN `in_email` VARCHAR(70), IN `in_massage` VARCHAR(2000), IN `in_insert_by` VARCHAR(100))
BEGIN
if query_type = 'insert' THEN
INSERT INTO `contact_us`( `fullname`, `email`, `message`, `inserted_by`) VALUES (in_fullname,in_email,in_massage, in_insert_by);

end IF;
END$$
DELIMITER ;


