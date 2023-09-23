ALTER TABLE `tax_payers` CHANGE `user_id` `user_id` INT(11) NULL;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_accounts`(IN `in_query_type` VARCHAR(20), IN `in_id` INT, IN `in_name` VARCHAR(255), IN `in_username` VARCHAR(255), IN `in_email` VARCHAR(255), IN `in_office_email` VARCHAR(255), IN `in_password` VARCHAR(255), IN `in_role` VARCHAR(255), IN `in_bvn` VARCHAR(11), IN `in_tin` VARCHAR(11), IN `in_org_tin` VARCHAR(11), IN `in_org_name` VARCHAR(200), IN `in_rc` VARCHAR(11), IN `in_account_type` VARCHAR(20), IN `in_phone` VARCHAR(15), IN `in_office_phone` VARCHAR(15), IN `in_state` VARCHAR(20), IN `in_lga` VARCHAR(100), IN `in_address` VARCHAR(200), IN `in_office_address` VARCHAR(200), IN `in_accessTo` VARCHAR(11))
BEGIN
  
    CALL in_number_generator('select', NULL, 'application_number', NULL,@Tax_ID);

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role, bvn, tin, org_tin, org_name, rc, account_type, phone, state, lga, address, office_address, accessTo, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_bvn, in_tin, in_org_tin, in_org_name, in_rc, in_account_type, in_phone, in_state, in_lga, in_address, in_office_address, in_accessTo, @Tax_ID); 
        
        INSERT INTO `tax_payers`(`name`, `username`, `email`, `role`, `bvn`, `tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `state`, `lga`, `address`) 
        VALUES (in_name,in_username,in_email,in_role,in_bvn,in_org_tin,@Tax_ID,in_org_name,in_rc,in_account_type,in_phone,in_state,in_lga,in_address);
        
        CALL in_number_generator('update', NULL, 'application_number', @Tax_ID,@void);

    ELSEIF in_query_type = 'update' THEN
        UPDATE users
        SET name = in_name, username = in_username, email = in_email, password = in_password, role = in_role, bvn = in_bvn, tin = in_org_tin,  tin = in_org_tin, org_name = in_org_name, rc = in_rc, account_type = in_account_type, phone = in_phone, state = in_state, lga = in_lga, address = in_address, office_address = in_office_address, accessTo = in_accessTo
        WHERE id = in_id;
    ELSEIF in_query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
ELSEIF in_query_type = 'select-user' THEN
 SELECT * FROM `users` u WHERE u.taxID LIKE CONCAT('%', in_tin, '%') OR u.nin LIKE CONCAT('%', in_tin, '%') OR u.org_tin OR u. email LIKE CONCAT('%', in_tin, '%') OR u.office_email LIKE CONCAT('%', in_tin, '%') OR u.office_phone LIKE CONCAT('%', in_tin, '%') OR u.phone LIKE CONCAT('%', in_tin, '%'); 

    END IF;
END$$
DELIMITER ;