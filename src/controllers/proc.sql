DELIMITER $$
DROP PROCEDURE IF EXISTS user_accounts $$
CREATE PROCEDURE user_accounts(
    IN query_type VARCHAR(20), 
    IN in_id VARCHAR(255), 
    IN in_name VARCHAR(255), 
    IN in_username VARCHAR(255), 
    IN in_email VARCHAR(255), 
    IN in_office_email VARCHAR(255), 
    IN in_password VARCHAR(255), 
    IN in_role VARCHAR(255), 
    IN in_bvn VARCHAR(11), 
    IN in_tin VARCHAR(11), 
    IN in_org_tin VARCHAR(11), 
    IN in_org_name VARCHAR(200), 
    IN in_rc VARCHAR(11), 
    IN in_account_type VARCHAR(20), 
    IN in_phone VARCHAR(15), 
    IN in_office_phone VARCHAR(15), 
    IN in_state VARCHAR(20), 
    IN in_lga VARCHAR(100), 
    IN in_address VARCHAR(200), 
    IN in_office_address VARCHAR(200), 
    IN in_mda_name VARCHAR(150), 
    IN in_mda_code VARCHAR(150), 
    IN in_department VARCHAR(150), 
    IN in_accessTo VARCHAR(300), 
    IN in_rank VARCHAR(100), 
    IN in_status VARCHAR(20), 
    IN in_tax_id VARCHAR(20),
    IN in_sector VARCHAR(20),
    IN in_ward VARCHAR(20),
    IN in_limit INT(10),
    IN in_offset INT(10))
BEGIN
  
    DECLARE Tax_ID, ins_user_id INT DEFAULT NULL;
    DECLARE reord_exists, total_rows INT;   

    IF query_type = 'insert' THEN
		# CALL in_number_generator('select', NULL, 'application_number', NULL, @Tax_ID);
        SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
        
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, rank,status, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank,in_status, Tax_ID); 
        SET ins_user_id = LAST_INSERT_ID();
        
		IF in_account_type = 'individual' OR in_account_type = 'org' THEN
			INSERT INTO tax_payers(ward,user_id, name, username, email, office_email, role, bvn, tin,org_tin, taxID, org_name, rc, account_type, phone, office_phone, state, lga, address, office_address) 
			VALUES (in_ward,ins_user_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, Tax_ID, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_address,in_office_address);

		END IF;
        
        UPDATE number_generator SET next_code = Tax_ID WHERE description='application_number';
		# CALL in_number_generator('update', NULL, 'application_number', @Tax_ID, @void);
		# UPDATE users SET taxID = @Tax_ID WHERE id = ins_user_id;
		# SELECT  @Tax_ID as taxID;

    ELSEIF query_type='create-admin' THEN
		SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
       INSERT INTO users (name, username, email,  password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, rank,sector)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, Tax_ID, in_rank,in_sector); 
        UPDATE number_generator SET next_code = Tax_ID WHERE description='application_number';
        
    ELSEIF  query_type = 'update-admin' THEN
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
            department = IFNULL(in_department, department),
            sector= IFNULL(in_sector, sector)
           
        WHERE id = in_id;
    ELSEIF query_type = 'update-taxpayer' THEN
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
             ward= IFNULL(in_ward, ward)
          WHERE taxID = in_tax_id;
         UPDATE users
        SET 
            name = IFNULL(in_name, name),
            username = IFNULL(in_username, username),
            email = IFNULL(in_email, email),
            phone = IFNULL(in_phone, phone),
            mda_name = IFNULL(in_mda_name, mda_name),
            mda_code = IFNULL(in_mda_code, mda_code),
            department = IFNULL(in_department, department)
          WHERE taxID = in_tax_id;
        -- SELECT statement here if needed
    ELSEIF query_type = 'update' THEN
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
    ELSEIF query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
    ELSEIF query_type = 'select-user' THEN
        SELECT * FROM tax_payers u WHERE   u.phone LIKE CONCAT('%', in_id, '%') OR u.email LIKE CONCAT('%', in_id, '%'); 
    ELSEIF query_type = 'select-tax-payer' THEN
        SELECT * FROM tax_payers u 
        WHERE u.taxID LIKE CONCAT('%', in_id, '%') 
        OR u.nin LIKE CONCAT('%', in_id, '%') 
        OR u.org_tin  LIKE CONCAT('%', in_id, '%')   
        OR u.email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_phone  LIKE CONCAT('%', in_id, '%')  
        OR u.phone  LIKE CONCAT('%', in_id, '%'); 
    ELSEIF query_type = 'add-account' THEN
        INSERT INTO tax_payers(user_id, name, username, email, office_email, role, bvn, tin,org_tin, taxID, org_name, rc, account_type, phone, office_phone, state, lga, ward, address, office_address) 
		VALUES (in_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, in_tax_id, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_ward, in_address,in_office_address);
    ELSEIF query_type = 'select-tax-payers' THEN
        IF in_account_type IS NOT NULL AND in_account_type !='' THEN
            SELECT COUNT(*) INTO @total_rows   FROM tax_payers WHERE account_type=in_account_type LIMIT in_offset, in_limit ;
            SELECT  x.*,  @total_rows as total_rows    FROM tax_payers x  WHERE x.account_type=in_account_type LIMIT in_offset, in_limit ;
        ELSE
            SELECT COUNT(*) INTO @total_rows   FROM tax_payers LIMIT in_offset, in_limit ;
           
            SELECT  x.*,  @total_rows as total_rows  FROM tax_payers x LIMIT in_offset, in_limit;
        END IF;
    END IF;
END $$
DELIMITER ;