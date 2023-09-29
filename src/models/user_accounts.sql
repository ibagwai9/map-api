DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_accounts`(IN `in_query_type` VARCHAR(20), IN `in_id` INT, IN `in_name` VARCHAR(255), IN `in_username` VARCHAR(255), IN `in_email` VARCHAR(255), IN `in_password` VARCHAR(255), IN `in_role` VARCHAR(255), IN `in_bvn` VARCHAR(11), IN `in_tin` VARCHAR(11), IN `in_company_name` VARCHAR(11), IN `in_rc` VARCHAR(11), IN `in_account_type` VARCHAR(11), IN `in_phone` VARCHAR(11), IN `in_state` VARCHAR(11), IN `in_lga` VARCHAR(11), IN `in_address` VARCHAR(11), IN `in_accessTo` VARCHAR(11))
BEGIN
	CALL in_number_generator('select', NULL, 'application_number', NULL,@Tax_ID);

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role, bvn, tin, company_name, rc, account_type, phone, state, lga, address, accessTo, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_bvn, in_tin, in_company_name, in_rc, in_account_type, in_phone, in_state, in_lga, in_address, in_accessTo, @Tax_ID);
        
        CALL in_number_generator('update', NULL, 'application_number', @Tax_ID,@void);

    ELSEIF in_query_type = 'update' THEN
        UPDATE users
        SET name = in_name, username = in_username, email = in_email, password = in_password, role = in_role, bvn = in_bvn, tin = in_tin, company_name = in_company_name, rc = in_rc, account_type = in_account_type, phone = in_phone, state = in_state, lga = in_lga, address = in_address, accessTo = in_accessTo
        WHERE id = in_id;
    ELSEIF in_query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
    END IF;
END$$
DELIMITER ;

ALTER TABLE `taxes` ADD `mda_name` VARCHAR(200) NULL DEFAULT NULL AFTER `tax_fee`, ADD `mda_code` VARCHAR(30) NULL DEFAULT NULL AFTER `mda_name`;