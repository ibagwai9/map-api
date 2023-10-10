CREATE TABLE `contact_us` ( `id` INT NOT NULL AUTO_INCREMENT , `fullname` VARCHAR(100) NULL DEFAULT NULL , `email` VARCHAR(60) NULL DEFAULT NULL , `message` VARCHAR(2000) NOT NULL , `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP , `inserted_by` VARCHAR(80) NULL DEFAULT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `contact_us`(IN `query_type` VARCHAR(50), IN `in_fullname` VARCHAR(100), IN `in_email` VARCHAR(70), IN `in_massage` VARCHAR(2000), IN `in_insert_by` VARCHAR(100))
BEGIN
if query_type = 'insert' THEN
INSERT INTO `contact_us`( `fullname`, `email`, `message`, `inserted_by`) VALUES (in_fullname,in_email,in_massage, in_insert_by);

end IF;
END$$
DELIMITER ;

-- //

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_accounts`(IN `in_query_type` VARCHAR(20), IN `in_id` VARCHAR(255), IN `in_name` VARCHAR(255), IN `in_username` VARCHAR(255), IN `in_email` VARCHAR(255), IN `in_office_email` VARCHAR(255), IN `in_password` VARCHAR(255), IN `in_role` VARCHAR(255), IN `in_bvn` VARCHAR(11), IN `in_tin` VARCHAR(11), IN `in_org_tin` VARCHAR(11), IN `in_org_name` VARCHAR(200), IN `in_rc` VARCHAR(11), IN `in_account_type` VARCHAR(20), IN `in_phone` VARCHAR(15), IN `in_office_phone` VARCHAR(15), IN `in_state` VARCHAR(20), IN `in_lga` VARCHAR(100), IN `in_address` VARCHAR(200), IN `in_office_address` VARCHAR(200), IN `in_mda_name` VARCHAR(150), IN `in_mda_code` VARCHAR(150), IN `in_department` VARCHAR(150), IN `in_accessTo` VARCHAR(300), IN `in_rank` VARCHAR(100))
BEGIN
  
    DECLARE Tax_ID INT;
        CALL in_number_generator('select', NULL, 'application_number', NULL,@Tax_ID);

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, rank, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank, @Tax_ID); 
        
        INSERT INTO `tax_payers`(`name`, `username`, `email`, `role`, `bvn`, `tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `state`, `lga`, `address`) 
        VALUES (in_name,in_username,in_email,in_role,in_bvn,in_org_tin,@Tax_ID,in_org_name,in_rc,in_account_type,in_phone,in_state,in_lga,in_address);
        
        CALL in_number_generator('update', NULL, 'application_number', @Tax_ID,@void);
    
    ELSEIF in_query_type='create-admin' THEN
       INSERT INTO users (name, username, email, password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, rank)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, @Tax_ID, in_rank); 
        
        
    ELSEIF  in_query_type = 'update-admin' THEN
        -- Update columns based on input parameters, maintaining initial values if not provided
        UPDATE users
        SET 
            name = IFNULL(in_name, name),
            username = IFNULL(in_username, username),
            email = IFNULL(in_email, email),
            password = IFNULL(in_password, password),
            role = IFNULL(in_role, role),
            account_type = IFNULL(in_account_type, account_type),
            phone = IFNULL(in_phone, phone),
            accessTo = IFNULL(in_accessTo, accessTo),
            mda_name = IFNULL(in_mda_name, mda_name),
            mda_code = IFNULL(in_mda_code, mda_code),
            department = IFNULL(in_department, department)
        WHERE id = in_id;
    ELSEIF in_query_type = 'update-taxpayer' THEN
        -- Update columns based on input parameters, maintaining initial values if not provided
        UPDATE tax_payers
        SET 
            name = IFNULL(in_name, name),
            username = IFNULL(in_username, username),
            email = IFNULL(in_email, email),
            role = IFNULL(in_role, role),
            bvn = IFNULL(in_bvn, bvn),
            org_tin = IFNULL(in_org_tin, org_tin),
            tin = IFNULL(in_tin, tin),
            org_name = IFNULL(in_org_name, org_name),
            rc = IFNULL(in_rc, rc),
            account_type = IFNULL(in_account_type, account_type),
            phone = IFNULL(in_phone, phone),
            state = IFNULL(in_state, state),
            lga = IFNULL(in_lga, lga),
            address = IFNULL(in_address, address),
            office_address = IFNULL(in_office_address, office_address),
            accessTo = IFNULL(in_accessTo, accessTo),
           rank = IFNULL(in_rank, rank)  
        WHERE user_id = in_id;
        -- SELECT statement here if needed
    ELSEIF in_query_type = 'update' THEN
        -- Update columns based on input parameters, maintaining initial values if not provided
        UPDATE users
        SET 
            name = IFNULL(in_name, name),
            username = IFNULL(in_username, username),
            email = IFNULL(in_email, email),
            password = IFNULL(in_password, password),
            role = IFNULL(in_role, role),
            account_type = IFNULL(in_account_type, account_type),
            phone = IFNULL(in_phone, phone)
        WHERE id = in_id;
    ELSEIF in_query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
    ELSEIF in_query_type = 'select-user' THEN
        SELECT * FROM `users` u WHERE   u.phone LIKE CONCAT('%', in_id, '%') OR u.email LIKE CONCAT('%', in_id, '%'); 
    ELSEIF in_query_type = 'select-tax-payer' THEN
        SELECT * FROM `tax_payers` u 
        WHERE u.taxID LIKE CONCAT('%', in_id, '%') 
        OR u.nin LIKE CONCAT('%', in_id, '%') 
        OR u.org_tin  LIKE CONCAT('%', in_id, '%')   
        OR u.email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_phone  LIKE CONCAT('%', in_id, '%')  
        OR u.phone  LIKE CONCAT('%', in_id, '%'); 
    END IF;
END$$
DELIMITER ;


ALTER TABLE `users` ADD `user_status` VARCHAR(50) NULL DEFAULT NULL AFTER `updatedAt`;
CREATE TABLE `department` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) NOT NULL,
  `type` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4
INSERT INTO `department`(`description`, `type`) VALUES ('Survey Department','LAND'),('GIS','LAND'),('Physical Planning','LAND'),('Special Assignment Dept. Contravention','LAND'),('SLTR','LAND'),('DEEPS','LAND'),('Land Department','LAND')