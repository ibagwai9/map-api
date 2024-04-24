DROP PROCEDURE IF EXISTS `mda_queries`;
DELIMITER $$
DROP PROCEDURE IF EXISTS `mda_queries`$$

CREATE  PROCEDURE `mda_queries`(
    IN `p_query_type` VARCHAR(50), 
    IN `p_mda_code` VARCHAR(15), 
    IN `p_sector` VARCHAR(15), 
    IN `p_start_date` DATE, 
    IN `p_end_date` DATE
    )
BEGIN 
IF p_sector IS NOT NULL AND p_sector!=''  THEN

    IF p_query_type = 'total-revenue' THEN
    SELECT SUM(cr) as total  FROM tax_transactions WHERE status IN ('paid','success') AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
    # AND   dateSettled >='2023-10-01'
    AND   sector = p_sector;
    ELSEIF p_query_type ='all' THEN
    SELECT DISTINCT mda_name, mda_code FROM taxes  WHERE   sector = p_sector;

    ELSEIF p_query_type ='all-mda-reports' THEN

        SELECT mda_name, SUM(cr) as total
        FROM tax_transactions
        WHERE mda_code = mda_code AND status IN ('paid', 'success')
        AND dateSettled >='2023-10-01' 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        AND   sector = p_sector
        GROUP BY   mda_name
        HAVING total > 0;

    ELSEIF p_query_type ='sectorly-reports' THEN

    SELECT sector, sum(cr) AS total 
        from tax_transactions 
        WHERE status IN ('paid','success') 
        AND sector = p_sector
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
    GROUP BY sector;
    ELSEIF p_query_type ='bankly-reports' THEN

        SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        AND   sector = p_sector
        GROUP BY bank_name;

    ELSEIF p_query_type ='monthly-reports' THEN

        SELECT MONTH(transaction_date) AS month, 
        
        YEAR(transaction_date) AS year,
        sum(cr) AS total 
            from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date) BETWEEN  p_start_date and p_end_date
        AND   sector = p_sector
        GROUP BY MONTH(transaction_date);

    ELSEIF p_query_type ='taxly-reports' THEN
        SELECT description, sum(cr) as total FROM tax_transactions WHERE status IN ('paid','success')
        AND   sector = p_sector
        group by description;
    ELSEIF p_query_type = 'mda-transactions' THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS total
        FROM tax_transactions y 
        WHERE    y.mda_code = p_mda_code  AND  y.status IN ('paid','success') AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        AND   y.dateSettled >='2023-10-01'
        AND   y.sector = p_sector
        GROUP BY y.reference_number;
    END IF;
ELSE IF p_mda_code IS NOT NULL  AND p_mda_code !='' THEN
    IF p_query_type = 'total-revenue' THEN

        SELECT SUM(cr) as total  FROM tax_transactions WHERE status IN ('paid','success') 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        AND   dateSettled >='2023-10-01'
        AND   mda_code = p_mda_code;
    ELSEIF p_query_type ='all-mda-reports' THEN

        SELECT mda_name, SUM(cr) as total
        FROM tax_transactions
        WHERE  status IN ('paid', 'success')
        AND dateSettled >='2023-10-01' 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        GROUP BY   mda_name
        HAVING total > 0;

    ELSEIF p_query_type ='bankly-reports' THEN

        SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        AND   mda_code = p_mda_code
        GROUP BY bank_name;

    ELSEIF p_query_type ='sectorly-reports' THEN

        SELECT sector, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        AND   mda_code = p_mda_code
        GROUP BY sector;

    ELSEIF p_query_type ='monthly-reports' THEN

        SELECT MONTH(transaction_date) AS month, 
        
        YEAR(transaction_date) AS year,
        sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date) BETWEEN  p_start_date and p_end_date
        AND   mda_code = p_mda_code
        GROUP BY MONTH(transaction_date);

    ELSEIF p_query_type ='taxly-reports' THEN
        SELECT description, sum(cr) as total FROM tax_transactions 
        WHERE status IN ('paid','success')
        AND   mda_code = p_mda_code
        group by description;
    ELSEIF p_query_type = 'mda-transactions' THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS total
        FROM tax_transactions y 
        WHERE    y.mda_code = p_mda_code 
        AND  y.status IN ('paid','success') 
        AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        AND   mda_code = p_mda_code
        AND   y.dateSettled >='2023-10-01'
        GROUP BY y.reference_number;
    END IF;
ELSE
    IF p_query_type = 'total-revenue' THEN

        SELECT SUM(cr) as total  FROM tax_transactions 
        WHERE status IN ('paid','success') 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date;
        # AND   dateSettled >='2023-10-01';

    ELSEIF p_query_type ='all' THEN
        SELECT DISTINCT mda_name, mda_code FROM taxes;
    ELSEIF p_query_type ='all-mda-reports' THEN

        SELECT mda_name, SUM(cr) as total
        FROM tax_transactions
        WHERE mda_code = mda_code AND status IN ('paid', 'success')
        AND dateSettled >='2023-10-01' 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        GROUP BY   mda_name
        HAVING total > 0;

    ELSEIF p_query_type ='bankly-reports' THEN

        SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        GROUP BY bank_name;

    ELSEIF p_query_type ='sectorly-reports' THEN

        SELECT sector, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        GROUP BY sector;

    ELSEIF p_query_type ='monthly-reports' THEN

        SELECT MONTH(transaction_date) AS month, 
        
        YEAR(transaction_date) AS year,
        sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date) BETWEEN  p_start_date and p_end_date
        GROUP BY MONTH(transaction_date);

    ELSEIF p_query_type ='taxly-reports' THEN
        SELECT description, sum(cr) as total FROM tax_transactions 
        WHERE status IN ('paid','success') 
        group by description;
    END IF;
   END IF;
END IF;
END;

DELIMITER $$
DROP PROCEDURE IF EXISTS print_report $$
CREATE PROCEDURE `print_report`(
    IN in_query_type VARCHAR(50), 
IN in_ref VARCHAR(50), 
IN in_user_id VARCHAR(50), 
IN in_from DATE, 
IN in_to DATE , 
IN in_mda_code VARCHAR(50), 
IN in_sector VARCHAR(50), 
IN in_user_name VARCHAR(50),
IN in_offset INT,
IN in_limit INT)
BEGIN
	DECLARE print_count INT;
	IF in_query_type = 'print' THEN	
     CALL print_logs('insert', in_user_id, in_user_name, in_ref );
    
		SELECT distinct printed INTO print_count FROM tax_transactions WHERE reference_number=in_ref;
        
        IF print_count >= 1 THEN
			UPDATE tax_transactions SET printed = printed + 1, printed_by = in_user_name WHERE reference_number=in_ref;
        ELSE
			UPDATE tax_transactions SET printed = 1, printed_by = in_user_name, printed_at = DATE(NOW()), printed_by=in_user_id WHERE reference_number=in_ref;
        END IF;
    ELSEIF in_query_type = 'view-logs' THEN
        SELECT p.*, t.description, t.status, t.tax_payer, t.dr as amount
        FROM print_logs p
        JOIN tax_transactions t ON p.ref_no = t.reference_number
        WHERE t.dr > 0 AND p.ref_no = in_ref;
ELSEIF in_query_type = 'summary' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0 AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'summary_by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0 AND printed_by=in_user_id AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'all_summary' then
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0;
	ELSEIF in_query_type = 'details-by-date' THEN 
		IF in_mda_code IS NOT NULL AND in_mda_code !='' THEN
            SELECT  
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE printed <> 0 AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(y.printed_at) BETWEEN in_from AND in_to AND y.mda_code = in_mda_code
        GROUP BY y.reference_number;
        ELSE
            SELECT  
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE printed <> 0 AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(y.printed_at) BETWEEN in_from AND in_to
        GROUP BY y.reference_number;
        END IF;
	ELSEIF in_query_type = 'details-by-date-and-user' THEN 
		SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE printed <> 0 and  FIND_IN_SET(sector, 'TAX,NON TAX,LAND,LGA,VEHICLES') > 0
            AND DATE(y.printed_at)  BETWEEN in_from AND in_to
        GROUP BY y.reference_number;
	ELSEIF in_query_type = 'view' THEN
	ELSEIF in_query_type = 'by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0 AND printed_by = in_user_id AND DATE(created_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'view-history' THEN 
        IF in_view ='all' THEN
            SELECT * FROM tax_transactions 
            WHERE dr>0 
            AND  DATE(created_at) BETWEEN in_from AND in_to 
            AND  FIND_IN_SET(sector, in_sector) > 0
            LIMIT in_limit
            OFFSET in_offset;
        ELSEIF in_view ='invoice' THEN
             SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND status ='saved' AND  FIND_IN_SET(sector, in_sector) > 0;
        ELSEIF in_view ='receipt' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND status ='paid' AND status!='saved' AND   FIND_IN_SET(sector, in_sector) > 0 AND   DATE(created_at) BETWEEN in_from AND in_to ;
        END IF;
	END IF;
END $$
DELIMITER;

-- 24/11/2023

ALTER TABLE `tax_payers` ADD `ward` VARCHAR(100) NULL DEFAULT NULL AFTER `lga`;

DELIMITER $$
DROP PROCEDURE  IF EXISTS `user_accounts`$$
CREATE PROCEDURE `user_accounts`(
    IN `in_query_type` VARCHAR(20), 
    IN `in_id` VARCHAR(255), 
    IN `in_name` VARCHAR(255), 
    IN `in_username` VARCHAR(255), 
    IN `in_email` VARCHAR(255), 
    IN `in_office_email` VARCHAR(255), 
    IN `in_password` VARCHAR(255), 
    IN `in_role` VARCHAR(255), 
    IN `in_bvn` VARCHAR(11), 
    IN `in_tin` VARCHAR(11), 
    IN `in_org_tin` VARCHAR(11), 
    IN `in_org_name` VARCHAR(200), 
    IN `in_rc` VARCHAR(11), 
    IN `in_account_type` VARCHAR(20), 
    IN `in_phone` VARCHAR(15), 
    IN `in_office_phone` VARCHAR(15), 
    IN `in_state` VARCHAR(20), 
    IN `in_lga` VARCHAR(100), 
    IN `in_ward` VARCHAR(100), 
    IN `in_address` VARCHAR(200), 
    IN `in_office_address` VARCHAR(200), 
    IN `in_mda_name` VARCHAR(150), 
    IN `in_mda_code` VARCHAR(150), 
    IN `in_department` VARCHAR(150), 
    IN `in_accessTo` VARCHAR(300), 
    IN `in_rank` VARCHAR(100), 
    IN `in_status` VARCHAR(20), 
    IN `in_tax_id` VARCHAR(20),
     IN `in_sector` VARCHAR(20)
    )
BEGIN
  
    DECLARE Tax_ID, ins_user_id INT DEFAULT NULL;
    
    DECLARE reord_exists INT;   

    IF in_query_type = 'insert' THEN
		# CALL in_number_generator('select', NULL, 'application_number', NULL, @Tax_ID);
        SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
        
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, `rank`,`status`, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank,in_status, Tax_ID); 
        SET ins_user_id = LAST_INSERT_ID();
        
		IF in_account_type = 'individual' OR in_account_type = 'org' THEN
			INSERT INTO `tax_payers`(user_id, `name`, `username`, `email`, `office_email`, `role`, `bvn`, `tin`,`org_tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `office_phone`, `state`, `lga`, `ward`, `address`, `office_address`) 
			VALUES (ins_user_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, Tax_ID, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_ward, in_address,in_office_address);

		END IF;
        
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
		# CALL in_number_generator('update', NULL, 'application_number', @Tax_ID, @void);
		# UPDATE users SET taxID = @Tax_ID WHERE id = ins_user_id;
		# SELECT  @Tax_ID as taxID;

    ELSEIF in_query_type='create-admin' THEN
        START TRANSACTION;
		SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
       INSERT INTO users (name, username, email,  password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, `rank`,sector)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, Tax_ID, in_rank,in_sector); 
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
        COMMIT;
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
            department = IFNULL(in_department, department),
            sector= IFNULL(in_sector, sector)
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
            ward = IFNULL(in_ward, ward),
            address = IFNULL(in_address, address),
            office_address = IFNULL(in_office_address, office_address)
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
END $$


-- 25/11/2023

ALTER TABLE `tax_transactions` ADD `phone` VARCHAR(15) NULL DEFAULT NULL AFTER `tax_payer`;



CREATE TABLE `print_logs` (
    id int (11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` int(9) NOT NULL,
  `printed_by` varchar(50) NOT NULL,
  `ref_no` varchar(20) NOT NULL,
  `printed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `user_id` (`user_id`),
    
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
);

DELIMITER $$
CREATE PROCEDURE print_logs (
	IN query_type VARCHAR(30),
	IN in_user_id VARCHAR(9),
    IN in_printed_by VARCHAR (50),
    IN in_ref_no VARCHAR(20)
    
) 

BEGIN
	IF query_type='insert' THEN
		INSERT INTO `print_logs`(`user_id`, `printed_by`, `ref_no`) VALUES (in_user_id, in_printed_by, in_ref_no);
    
    ELSEIF query_type = 'select' THEN
    	SELECT * FROM  `print_logs` WHERE ref_no = in_ref_no;
	END IF;
END $$



DELIMITER $$
DROP PROCEDURE IF EXISTS HandleTaxTransaction $$
CREATE PROCEDURE `HandleTaxTransaction`(
IN `p_query_type` ENUM('view_invoice','view_payment',"paid_invoice",'insert_payment','insert_invoice','check_balance','view_payer_ledger','view_agent_history','approve_payment'), 
IN `p_user_id` VARCHAR(9), 
IN `p_agent_id` VARCHAR(9), 
IN `p_tax_payer` VARCHAR(100), 
IN `p_phone` VARCHAR(100), 
IN `p_mda_name` VARCHAR(300), 
IN `p_mda_code` VARCHAR(50), 
IN `p_item_code` VARCHAR(50), 
IN `p_rev_code` VARCHAR(50), 
IN `p_description` VARCHAR(500), 
IN `p_nin_id` VARCHAR(12), 
IN `p_tin` VARCHAR(12), 
IN `p_amount` DECIMAL(20,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice'), 
IN `p_status` VARCHAR(20), 
IN `p_reference_number` VARCHAR(50), 
IN `p_department` VARCHAR(150), 
IN `p_service_category` VARCHAR(150), 
IN `p_tax_station` VARCHAR(50), 
IN `p_sector` VARCHAR(50), 
IN `p_mda_var` VARCHAR(50), 
IN `p_mda_val` VARCHAR(50), 
IN `p_start_date` DATE, 
IN `p_end_date` DATE)
BEGIN
  IF p_query_type = 'insert_payment' THEN
    -- Insert a payment transaction
    INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val
    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
  ELSEIF p_query_type = 'paid_invoice' THEN
         SELECT x.*, 
       COALESCE(x.phone, t.phone) AS payer_phone
FROM tax_transactions x
LEFT JOIN tax_payers t ON x.user_id = t.taxID
WHERE x.reference_number = p_reference_number  AND  `status` in ("success","paid") and logId is not null;

  ELSEIF p_query_type = 'view_payment' THEN
    -- View payment transaction
    SELECT * FROM tax_transactions WHERE reference_number = p_reference_number;
  ELSEIF p_query_type = 'insert_invoice' THEN
    -- Insert an invoice transaction
       INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val

    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
   ELSEIF p_query_type = 'check_balance' THEN
    -- Query user's balance based on their user_id
    SELECT SUM(CASE WHEN transaction_type = 'payment' THEN cr ELSE -dr END) AS balance
    FROM tax_transactions
    WHERE user_id = p_user_id;
 ELSEIF p_query_type = 'view_payer_ledger' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
        GROUP BY y.reference_number;
    END IF;
 ELSEIF p_query_type = 'view_agent_history' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr  

        FROM tax_transactions y 
        WHERE y.agent_id = p_agent_id
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr ,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr 
        FROM tax_transactions y 
        WHERE y.agent = p_agent_id 
        GROUP BY y.reference_number;
    END IF;
  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
    
ELSEIF p_query_type = 'view_invoice' THEN
  SELECT x.*, 
       COALESCE(x.phone, t.phone) AS payer_phone
FROM tax_transactions x
LEFT JOIN tax_payers t ON x.user_id = t.taxID
WHERE x.reference_number = p_reference_number;

ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END $$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS print_report $$
CREATE PROCEDURE `print_report`(
    IN in_query_type VARCHAR(50), 
    IN in_ref VARCHAR(50), 
    IN in_user_id VARCHAR(50), 
    IN `in_user_name` VARCHAR(50),
    IN in_from DATE, 
    IN in_to DATE , 
    IN in_mda_code VARCHAR(50), 
    IN in_sector VARCHAR(50),
    IN `in_view` VARCHAR(50),
    IN in_offset INT,
    IN in_limit INT
)
BEGIN
	DECLARE print_count, total_prints INT;
	DECLARE total_rows, total_revenue DOUBLE;

	IF in_query_type = 'print' THEN
        CALL print_logs('insert', in_user_id, in_user_name, in_ref );
		SELECT  (printed +1) INTO print_count FROM tax_transactions WHERE reference_number=in_ref  LIMIT 1;
		IF print_count > 2 THEN
        	UPDATE tax_transactions t SET t.printed = (t.printed+1) WHERE reference_number=in_ref;
    	ELSE
    		UPDATE tax_transactions t SET t.printed = (t.printed+1), printed_at = DATE(NOW()), printed_by=in_user_name WHERE reference_number=in_ref;
    	END IF;
    ELSEIF in_query_type = 'view-logs' THEN
        SELECT p.*, t.description, t.tax_payer, t.dr as amount, t.status, (SELECT x.printed FROM tax_transactions x WHERE x.reference_number = in_ref LIMIT 1) AS printed, t.paymentdate
        FROM tax_transactions t
        LEFT JOIN print_logs p ON p.ref_no = t.reference_number
        WHERE t.dr > 0 AND t.reference_number  = in_ref;
    ELSEIF in_query_type = 'summary' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'summary_by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND printed_by=in_user_id AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'all_summary' then
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0;
	ELSEIF in_query_type = 'details-by-date' THEN

        IF in_mda_code IS NOT NULL AND in_mda_code != '' THEN
            -- Fetch paginated results with total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(printed) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to AND y.mda_code = in_mda_code
            LIMIT in_offset, in_limit;

        ELSE

           -- Fetch  total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(printed) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            -- Fetch paginated results with total rows
            SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to
            LIMIT in_offset, in_limit;
        END IF;
    ELSEIF in_query_type = 'total-by-date' THEN 
        SELECT SUM(dr) AS total_revenue FROM tax_transactions
                WHERE status !='saved' AND logId IS NOT NULL AND printed > 0 AND FIND_IN_SET(sector, in_sector) > 0 AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'details-by-date-and-user' THEN 
		
        -- Fetch paginated results with total rows
        SELECT COUNT(*) INTO @total_rows
        FROM tax_transactions
        WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(printed_at) BETWEEN in_from AND in_to;

        SELECT SUM(dr) INTO @total_revenue
        FROM tax_transactions
        WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(printed_at) BETWEEN in_from AND in_to;

           SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.printed_by = in_user_name AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to
            GROUP BY y.reference_number 
            LIMIT in_offset, in_limit;
	ELSEIF in_query_type = 'total-by-date-and-user' THEN 
        SELECT SUM(dr) AS total_revenue FROM tax_transactions
                WHERE status !='saved' AND logId IS NOT NULL AND printed > 0 AND FIND_IN_SET(sector, in_sector) > 0 AND printed_by = in_user_name AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'count-receipt' THEN  
        SELECT COUNT(*) as row_counts FROM tax_transactions 
        WHERE printed > 0 
        AND FIND_IN_SET(sector, in_sector) > 0
        AND DATE(created_at) BETWEEN in_from AND in_to;
    ELSEIF in_query_type = 'by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND printed_by = in_user_id AND DATE(created_at) BETWEEN in_from AND in_to;
        ELSEIF in_query_type = 'view-summary' THEN 
            IF in_mda_code IS NOT NULL THEN
                SELECT department, mda_name, sector, SUM(dr) AS total, in_from  AS start_date, in_to AS end_date
                FROM tax_transactions
                WHERE dr > 0
                AND status IN ('paid', 'success')
                AND mda_code = in_mda_code
                AND DATE(created_at) BETWEEN in_from AND in_to
                GROUP BY department, sector;
           ELSE
                SELECT department, mda_name, sector, SUM(dr) AS total, in_from  AS start_date, in_to AS end_date
                FROM tax_transactions
                WHERE dr > 0
                AND status IN ('paid', 'success')
                AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN in_from AND in_to
                GROUP BY department, sector;
           END IF;
        ELSEIF in_query_type = 'view-items-summary' THEN 
            IF in_mda_code IS NOT NULL THEN
                SELECT department, sector, mda_name, `description`, in_from  AS start_date, in_to AS end_date, SUM(cr) AS total FROM tax_transactions
                WHERE cr > 0
                AND status IN ('paid', 'success')
                AND mda_code = in_mda_code
                AND DATE(created_at) BETWEEN  in_from AND in_to
                GROUP BY department, mda_name, `description`,  sector;
            ELSE
                SELECT department, sector, mda_name, `description`, in_from  AS start_date, in_to AS end_date, SUM(cr) AS total FROM tax_transactions
                WHERE cr > 0
                AND status IN ('paid', 'success')
                AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN  in_from AND in_to
                GROUP BY department, mda_name, `description`,  sector;
            END IF;
    ELSEIF in_query_type = 'view-history' THEN 
        IF in_view ='all' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue

             FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(x.sector, in_sector) > 0   
                LIMIT in_offset, in_limit;

        ELSEIF in_view ='invoice' THEN
        
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status ='saved'
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions 
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status ='saved'
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue
            FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.created_at) BETWEEN in_from AND in_to AND x.status ='saved' AND  FIND_IN_SET(x.sector, in_sector) > 0
            LIMIT in_offset, in_limit;
        ELSEIF in_view ='receipt' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue
                 FROM tax_transactions x WHERE x.dr>0 AND x.status IN('paid','success')  AND   FIND_IN_SET(x.sector, in_sector) > 0 AND   DATE(x.created_at) BETWEEN in_from AND in_to 
             LIMIT in_offset, in_limit;
        END IF;
    ELSEIF in_query_type = 'search-history' THEN 
            SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0   
            AND reference_number LIKE CONCAT('%',in_ref,'%')
            LIMIT in_offset, in_limit;
    ELSEIF in_query_type = 'count-history' THEN  
        IF in_view ='all' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND  DATE(dateSettled) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0;          
        ELSEIF in_view ='invoice' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND  DATE(dateSettled) BETWEEN in_from AND in_to AND status ='saved' AND  FIND_IN_SET(sector, in_sector) > 0;
         ELSEIF in_view ='receipt' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND status IN('paid','success')  AND   FIND_IN_SET(sector, in_sector) > 0 AND   DATE(dateSettled) BETWEEN in_from AND in_to ;
        END IF;
    END IF;
END $$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS HandleTaxTransaction $$
CREATE PROCEDURE `HandleTaxTransaction`(
IN `p_query_type` ENUM('view_invoice','view_payment',"paid_invoice",'insert_payment','insert_invoice','check_balance','view_payer_ledger','view_agent_history','approve_payment'), 
IN `p_user_id` VARCHAR(9), 
IN `p_agent_id` VARCHAR(9), 
IN `p_tax_payer` VARCHAR(100), 
IN `p_phone` VARCHAR(100), 
IN `p_mda_name` VARCHAR(300), 
IN `p_mda_code` VARCHAR(50), 
IN `p_item_code` VARCHAR(50), 
IN `p_rev_code` VARCHAR(50), 
IN `p_description` VARCHAR(500), 
IN `p_nin_id` VARCHAR(12), 
IN `p_tin` VARCHAR(12), 
IN `p_amount` DECIMAL(20,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice'), 
IN `p_status` VARCHAR(20), 
IN `p_invoice_status` VARCHAR(20), 
IN `p_reference_number` VARCHAR(50), 
IN `p_department` VARCHAR(150), 
IN `p_service_category` VARCHAR(150), 
IN `p_tax_station` VARCHAR(50), 
IN `p_sector` VARCHAR(50), 
IN `p_mda_var` VARCHAR(50), 
IN `p_mda_val` VARCHAR(50), 
IN `p_start_date` DATE, 
IN `p_end_date` DATE)
BEGIN
  IF p_query_type = 'insert_payment' THEN
    -- Insert a payment transaction
    INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        invoice_status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val
    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_invoice_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
  ELSEIF p_query_type = 'paid_invoice' THEN
         SELECT x.*, 
       COALESCE(x.phone, t.phone) AS payer_phone
FROM tax_transactions x
LEFT JOIN tax_payers t ON x.user_id = t.taxID
WHERE x.reference_number = p_reference_number  AND  `status` in ("success","paid") and logId is not null;

  ELSEIF p_query_type = 'view_payment' THEN
    -- View payment transaction
    SELECT * FROM tax_transactions WHERE reference_number = p_reference_number;
  ELSEIF p_query_type = 'insert_invoice' THEN
    -- Insert an invoice transaction
       INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        invoice_status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val

    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_invoice_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
   ELSEIF p_query_type = 'check_balance' THEN
    -- Query user's balance based on their user_id
    SELECT SUM(CASE WHEN transaction_type = 'payment' THEN cr ELSE -dr END) AS balance
    FROM tax_transactions
    WHERE user_id = p_user_id;
 ELSEIF p_query_type = 'view_payer_ledger' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
        GROUP BY y.reference_number;
    END IF;
 ELSEIF p_query_type = 'view_agent_history' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr  

        FROM tax_transactions y 
        WHERE y.agent_id = p_agent_id
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr ,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr 
        FROM tax_transactions y 
        WHERE y.agent = p_agent_id 
        GROUP BY y.reference_number;
    END IF;
  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
    
ELSEIF p_query_type = 'view_invoice' THEN
  SELECT x.*, 
       COALESCE(x.phone, t.phone) AS payer_phone
FROM tax_transactions x
LEFT JOIN tax_payers t ON x.user_id = t.taxID
WHERE x.reference_number = p_reference_number;

ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END $$
DELIMITER ;



ALTER TABLE `tax_transactions` ADD `invoice_status` VARCHAR(30) NOT NULL DEFAULT '' AFTER `status`;


DELIMITER $$
DROP PROCEDURE IF EXISTS user_accounts $$
CREATE PROCEDURE `user_accounts`(
    IN `in_query_type` VARCHAR(20), 
    IN `in_id` VARCHAR(255), 
    IN `in_name` VARCHAR(255), 
    IN `in_username` VARCHAR(255), 
    IN `in_email` VARCHAR(255), 
    IN `in_office_email` VARCHAR(255), 
    IN `in_password` VARCHAR(255), 
    IN `in_role` VARCHAR(255), 
    IN `in_bvn` VARCHAR(11), 
    IN `in_tin` VARCHAR(11), 
    IN `in_org_tin` VARCHAR(11), 
    IN `in_org_name` VARCHAR(200), 
    IN `in_rc` VARCHAR(11), 
    IN `in_account_type` VARCHAR(20), 
    IN `in_phone` VARCHAR(15), 
    IN `in_office_phone` VARCHAR(15), 
    IN `in_state` VARCHAR(20), 
    IN `in_lga` VARCHAR(100), 
    IN `in_address` VARCHAR(200), 
    IN `in_office_address` VARCHAR(200), 
    IN `in_mda_name` VARCHAR(150), 
    IN `in_mda_code` VARCHAR(150), 
    IN `in_department` VARCHAR(150), 
    IN `in_accessTo` VARCHAR(300), 
    IN `in_rank` VARCHAR(100), 
    IN `in_status` VARCHAR(20), 
    IN `in_tax_id` VARCHAR(20),
     IN `in_sector` VARCHAR(20),
      IN `in_ward` VARCHAR(20)
    )
BEGIN
  
    DECLARE Tax_ID, ins_user_id INT DEFAULT NULL;
    
    DECLARE reord_exists INT;   

    IF in_query_type = 'insert' THEN
		# CALL in_number_generator('select', NULL, 'application_number', NULL, @Tax_ID);
        SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
        
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, `rank`,`status`, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank,in_status, Tax_ID); 
        SET ins_user_id = LAST_INSERT_ID();
        
		IF in_account_type = 'individual' OR in_account_type = 'org' THEN
			INSERT INTO `tax_payers`(ward,user_id, `name`, `username`, `email`, `office_email`, `role`, `bvn`, `tin`,`org_tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `office_phone`, `state`, `lga`, `address`, `office_address`) 
			VALUES (in_ward,ins_user_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, Tax_ID, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_address,in_office_address);

		END IF;
        
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
		# CALL in_number_generator('update', NULL, 'application_number', @Tax_ID, @void);
		# UPDATE users SET taxID = @Tax_ID WHERE id = ins_user_id;
		# SELECT  @Tax_ID as taxID;

    ELSEIF in_query_type='create-admin' THEN
		SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
       INSERT INTO users (name, username, email,  password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, `rank`,sector)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, Tax_ID, in_rank,in_sector); 
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
        
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
            department = IFNULL(in_department, department),
            sector= IFNULL(in_sector, sector)
           
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
    ELSEIF in_query_type = 'add-account' THEN
    
        INSERT INTO `tax_payers`(user_id, `name`, `username`, `email`, `office_email`, `role`, `bvn`, `tin`,`org_tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `office_phone`, `state`, `lga`, `ward`, `address`, `office_address`) 
		VALUES (in_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, in_tax_id, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_ward, in_address,in_office_address);

    END IF;
END $$
DELIMITER ;

UPDATE  tax_transactions SET remark='', status='PAID', dateSettled='2024-01-19', paymentdate='2024-01-19', logId=(LPAD(FLOOR(RAND() * 100000000), 8, '0')) where  
 reference_number IN  (112240117103868,
11224011710327)

DROP TABLE IF EXISTS `payment_remarks`;

CREATE TABLE `payment_remarks` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ref_no` varchar(20) NOT NULL,
  `remark` varchar(200) NOT NULL,
  `remarked_by` varchar(50) DEFAULT NULL,
  `staff_id` int(8) NOT NULL,
  `remarked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ref_no` (`ref_no`),
  CONSTRAINT `payment_remarks_ibfk_1` FOREIGN KEY (`ref_no`) REFERENCES `tax_transactions` (`reference_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$
DROP PROCEDURE IF EXISTS  `payment_remarks` $$
CREATE PROCEDURE payment_remarks 
(   IN query_type VARCHAR(20),
    IN in_id int(10),
    IN in_ref_no int(20),
    IN in_remark varchar(200),
    IN in_remarked_by varchar (50),
    IN in_staff_id int(8) )

BEGIN 

IF query_type = 'create' THEN
    INSERT INTO `payment_remarks`(`ref_no`, `remark`, `remark_by`, `staff_id`) 
    VALUES ( in_ref_no, in_remark, in_remark_by, in_staff_id);

ELSEIF query_type ='select' THEN
    SELECT * FROM `payment_remarks` WHERE ref_no = in_ref_no;
END IF;

END $$


CREATE DEFINER=`sanda_user`@`%` PROCEDURE `print_report`(
    IN in_query_type VARCHAR(50), 
    IN in_ref VARCHAR(50), 
    IN in_user_id VARCHAR(50), 
    IN `in_user_name` VARCHAR(50),
    IN in_from DATE, 
    IN in_to DATE , 
    IN in_mda_code VARCHAR(50), 
    IN in_sector VARCHAR(50),
    IN `in_view` VARCHAR(50),
    IN in_offset INT,
    IN in_limit INT
)
BEGIN
	DECLARE print_count, total_prints INT;
	DECLARE total_rows, total_revenue DOUBLE;

	IF in_query_type = 'print' THEN
        CALL print_logs('insert', in_user_id, in_user_name, in_ref );
		SELECT  (printed +1) INTO print_count FROM tax_transactions WHERE reference_number=in_ref  LIMIT 1;
		IF print_count > 1 THEN
        	UPDATE tax_transactions t SET t.printed = (t.printed+1) WHERE reference_number=in_ref;
    	ELSE
    		UPDATE tax_transactions t SET t.printed = (t.printed+1), printed_at = DATE(NOW()), printed_by=in_user_name WHERE reference_number=in_ref;
    	END IF;
    ELSEIF in_query_type = 'view-logs' THEN
        SELECT p.*, t.description, t.tax_payer, t.dr as amount, t.status, (SELECT x.printed FROM tax_transactions x WHERE x.reference_number = in_ref LIMIT 1) AS printed, t.paymentdate
        FROM tax_transactions t
        LEFT JOIN print_logs p ON p.ref_no = t.reference_number
        WHERE t.dr > 0 AND t.reference_number  = in_ref;
    ELSEIF in_query_type = 'summary' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'summary_by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND printed_by=in_user_id AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'all_summary' then
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0;
	ELSEIF in_query_type = 'details-by-date' THEN

        IF in_mda_code IS NOT NULL AND in_mda_code != '' THEN
            -- Fetch paginated results with total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to AND y.mda_code = in_mda_code
            LIMIT in_offset, in_limit;

        ELSE

           -- Fetch  total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            -- Fetch paginated results with total rows
            SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to
            LIMIT in_offset, in_limit;
        END IF;
        ELSEIF in_query_type = 'departmental-receipt-summary' THEN

        IF in_mda_code IS NOT NULL AND in_mda_code != '' THEN
            -- Fetch paginated results with total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT  
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                 SUM(x.dr)  AS total,
                 COUNT(*)  AS total_printed,
                  x.department,  x.mda_name,  x.sector, in_from  AS start_date, in_to AS end_date
            FROM tax_transactions x 
            WHERE x.printed > 0 AND x.logId IS NOT NULL AND FIND_IN_SET(x.sector, in_sector) > 0
                AND DATE(x.printed_at) BETWEEN in_from AND in_to AND x.mda_code = in_mda_code
            GROUP BY department, mda_name, sector;

        ELSE

           -- Fetch  total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            -- Fetch paginated results with total rows
            SELECT  
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                SUM(x.cr)  AS total,
                 COUNT(*)  AS total_printed,
                  x.department,  x.mda_name,   x.sector, in_from  AS start_date, in_to AS end_date
            FROM tax_transactions x 
            WHERE y.printed > 0 AND x.logId IS NOT NULL AND FIND_IN_SET(x.sector, in_sector) > 0
                AND DATE(x.printed_at) BETWEEN in_from AND in_to 
            GROUP BY department, mda_name, sector;
        END IF;
    ELSEIF in_query_type = 'items-receipt-summary' THEN

        IF in_mda_code IS NOT NULL AND in_mda_code != '' THEN
            -- Fetch paginated results with total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
             AND mda_code = in_mda_code
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT  
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                SUM(x.dr) AS total,
                  x.department,  x.mda_name,  x.`description`,   x.sector, in_from  AS start_date, in_to AS end_date
            FROM tax_transactions x 
            WHERE x.printed > 0 AND x.logId IS NOT NULL AND FIND_IN_SET(x.sector, in_sector) > 0
                AND DATE(x.printed_at) BETWEEN in_from AND in_to AND x.mda_code = in_mda_code
            GROUP BY  mda_name, `description`,  sector;

        ELSE

           -- Fetch  total rows
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;

            SELECT COUNT(*) INTO @total_prints
            FROM tax_transactions
            WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(printed_at) BETWEEN in_from AND in_to;
            -- Fetch paginated results with total rows
            SELECT  
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                @total_prints AS total_prints,
                SUM(x.cr)  AS total,
                  x.department,  x.mda_name,  x.`description`,   x.sector, in_from  AS start_date, in_to AS end_date
            FROM tax_transactions x 
            WHERE x.printed > 0 AND x.logId IS NOT NULL AND FIND_IN_SET(x.sector, in_sector) > 0
                AND DATE(x.printed_at) BETWEEN in_from AND in_to 
            GROUP BY  mda_name, `description`,  sector;
        END IF;
    ELSEIF in_query_type = 'total-by-date' THEN 
        SELECT SUM(dr) AS total_revenue FROM tax_transactions
                WHERE status !='saved' AND logId IS NOT NULL AND printed > 0 AND FIND_IN_SET(sector, in_sector) > 0 AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'details-by-date-and-user' THEN 
		
        -- Fetch paginated results with total rows
        SELECT COUNT(*) INTO @total_rows
        FROM tax_transactions
        WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(printed_at) BETWEEN in_from AND in_to;

        SELECT SUM(dr) INTO @total_revenue
        FROM tax_transactions
        WHERE printed > 0 AND logId IS NOT NULL AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(printed_at) BETWEEN in_from AND in_to;

           SELECT  
                y.*,
                @total_rows AS total_rows,
                @total_revenue AS total_revenue,
                (SELECT SUM(x.dr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS dr 
            FROM tax_transactions y 
            WHERE y.printed > 0 AND y.printed_by = in_user_name AND y.logId IS NOT NULL AND FIND_IN_SET(y.sector, in_sector) > 0
                AND DATE(y.printed_at) BETWEEN in_from AND in_to
            GROUP BY y.reference_number 
            LIMIT in_offset, in_limit;
	ELSEIF in_query_type = 'total-by-date-and-user' THEN 
        SELECT SUM(dr) AS total_revenue FROM tax_transactions
                WHERE status !='saved' AND logId IS NOT NULL AND printed > 0 AND FIND_IN_SET(sector, in_sector) > 0 AND printed_by = in_user_name AND DATE(printed_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'count-receipt' THEN  
        SELECT COUNT(*) as row_counts FROM tax_transactions 
        WHERE printed > 0 
        AND FIND_IN_SET(sector, in_sector) > 0
        AND DATE(created_at) BETWEEN in_from AND in_to;
    ELSEIF in_query_type = 'by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed > 0 AND printed_by = in_user_id AND DATE(created_at) BETWEEN in_from AND in_to;
        ELSEIF in_query_type = 'view-summary' THEN 
            IF in_mda_code IS NOT NULL THEN
                SELECT department, mda_name, sector,COUNT(*)  AS total_printed, SUM(dr) AS total, in_from  AS start_date, in_to AS end_date
                FROM tax_transactions
                WHERE dr > 0
                AND status IN ('paid', 'success')
                AND mda_code = in_mda_code
                AND DATE(created_at) BETWEEN in_from AND in_to
                GROUP BY department, sector;
           ELSE
                SELECT department, mda_name, sector,COUNT(*)  AS total_printed, SUM(dr) AS total, in_from  AS start_date, in_to AS end_date
                FROM tax_transactions
                WHERE dr > 0
                AND status IN ('paid', 'success')
                AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN in_from AND in_to
                GROUP BY department, sector;
           END IF;
 ELSEIF in_query_type = 'view-items-summary' THEN 
            IF in_mda_code IS NOT NULL THEN
                SELECT COUNT(*) INTO @total_rows
                FROM tax_transactions 
                WHERE  cr > 0
                AND status IN ('paid', 'success')
                AND mda_code = in_mda_code
                AND DATE(created_at) BETWEEN  in_from AND in_to;

                SELECT @total_rows AS total_rows,
                  x.department, x.sector, x.mda_name, x.`description`, in_from  AS start_date, in_to AS end_date, SUM(x.cr) AS total FROM tax_transactions x
                WHERE x.cr > 0
                AND x.status IN ('paid', 'success')
                AND x.mda_code = in_mda_code
                AND DATE(x.created_at) BETWEEN  in_from AND in_to
                GROUP BY department, mda_name, `description`,  sector;
            ELSE
                  SELECT COUNT(*) INTO @total_rows
                FROM tax_transactions  
                WHERE cr > 0
                AND status IN ('paid', 'success')
                AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN  in_from AND in_to;

                SELECT x.department, x.sector, x.mda_name, x.`description`, in_from  AS start_date, in_to AS end_date, SUM(x.cr) AS total FROM tax_transactions x
                WHERE x.cr > 0
                AND x.status IN ('paid', 'success')
                AND FIND_IN_SET(x.sector, in_sector) > 0
                AND DATE(x.created_at) BETWEEN  in_from AND in_to
                GROUP BY department, mda_name, `description`,  sector;
            END IF;
    ELSEIF in_query_type = 'view-history' THEN 
        IF in_view ='all' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
                AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue

             FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(x.sector, in_sector) > 0   
                LIMIT in_offset, in_limit;

        ELSEIF in_view ='invoice' THEN
        
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status ='saved'
                AND DATE(created_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions 
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status ='saved'
                AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue
            FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.created_at) BETWEEN in_from AND in_to AND x.status ='saved' AND  FIND_IN_SET(x.sector, in_sector) > 0
            LIMIT in_offset, in_limit;
        ELSEIF in_view ='receipt' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
            AND DATE(created_at) BETWEEN in_from AND in_to;

            SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
            AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue
                 FROM tax_transactions x WHERE x.dr>0 AND x.status IN('paid','success')  AND   FIND_IN_SET(x.sector, in_sector) > 0 AND   DATE(x.created_at) BETWEEN in_from AND in_to 
             LIMIT in_offset, in_limit;
        END IF;
    ELSEIF in_query_type = 'search-history' THEN 
            SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0   
            AND reference_number LIKE CONCAT('%',in_ref,'%')
            LIMIT in_offset, in_limit;
    ELSEIF in_query_type = 'count-history' THEN  
        IF in_view ='all' THEN
         SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;

        SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue 
             FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.dateSettled) BETWEEN in_from AND in_to AND  FIND_IN_SET(x.sector, in_sector) > 0;          
        ELSEIF in_view ='invoice' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;

        SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue 
             FROM tax_transactions x WHERE x.dr>0 AND  DATE(x.dateSettled) BETWEEN in_from AND in_to AND x.status ='saved' AND  FIND_IN_SET(x.sector, in_sector) > 0;
         ELSEIF in_view ='receipt' THEN
            SELECT COUNT(*) INTO @total_rows
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;

        SELECT SUM(dr) INTO @total_revenue
            FROM tax_transactions
            WHERE  dr>0 AND FIND_IN_SET(sector, in_sector) > 0
            AND status IN('paid','success')
                AND DATE(created_at) BETWEEN in_from AND in_to;
            
            SELECT x.*, @total_rows AS total_rows,
                 @total_revenue AS total_revenue 
             FROM tax_transactions x WHERE x.dr>0 AND x.status IN('paid','success')  AND   FIND_IN_SET(x.sector, in_sector) > 0 AND   DATE(x.dateSettled) BETWEEN in_from AND in_to ;
        END IF;
    END IF;
END





ALTER TABLE `tax_payers` ADD `nin` INT NULL DEFAULT NULL AFTER `bvn`;


DELIMITER $$
DROP PROCEDURE IF EXISTS user_accounts $$
CREATE PROCEDURE `user_accounts`(
    IN `query_type` VARCHAR(20), 
    IN `in_id` VARCHAR(255), 
    IN `in_name` VARCHAR(255), 
    IN `in_username` VARCHAR(255), 
    IN `in_email` VARCHAR(255), 
    IN `in_office_email` VARCHAR(255), 
    IN `in_password` VARCHAR(255), 
    IN `in_role` VARCHAR(255), 
    IN `in_bvn` VARCHAR(11), 
    IN `in_tin` VARCHAR(11), 
    IN `in_org_tin` VARCHAR(11), 
    IN `in_org_name` VARCHAR(200), 
    IN `in_rc` VARCHAR(11), 
    IN `in_account_type` VARCHAR(20), 
    IN `in_phone` VARCHAR(15), 
    IN `in_office_phone` VARCHAR(15), 
    IN `in_state` VARCHAR(20), 
    IN `in_lga` VARCHAR(100), 
    IN `in_address` VARCHAR(200), 
    IN `in_office_address` VARCHAR(200), 
    IN `in_mda_name` VARCHAR(150), 
    IN `in_mda_code` VARCHAR(150), 
    IN `in_department` VARCHAR(150), 
    IN `in_accessTo` VARCHAR(300), 
    IN `in_rank` VARCHAR(100), 
    IN `in_status` VARCHAR(20), 
    IN `in_tax_id` VARCHAR(20),
    IN `in_sector` VARCHAR(20),
    IN `in_ward` VARCHAR(20),
    IN `in_limit` INT(10),
    IN `in_offset` INT(10))
BEGIN
  
    DECLARE Tax_ID, ins_user_id INT DEFAULT NULL;
    DECLARE reord_exists, total_rows INT;   

    IF query_type = 'insert' THEN
		# CALL in_number_generator('select', NULL, 'application_number', NULL, @Tax_ID);
        SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
        
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, `rank`,`status`, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank,in_status, Tax_ID); 
        SET ins_user_id = LAST_INSERT_ID();
        
		IF in_account_type = 'individual' OR in_account_type = 'org' THEN
			INSERT INTO `tax_payers`(ward,user_id, `name`, `username`, `email`, `office_email`, `role`, `bvn`, `tin`,`org_tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `office_phone`, `state`, `lga`, `address`, `office_address`) 
			VALUES (in_ward,ins_user_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, Tax_ID, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_address,in_office_address);

		END IF;
        
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
		# CALL in_number_generator('update', NULL, 'application_number', @Tax_ID, @void);
		# UPDATE users SET taxID = @Tax_ID WHERE id = ins_user_id;
		# SELECT  @Tax_ID as taxID;

    ELSEIF query_type='create-admin' THEN
		SELECT next_code + 1 INTO Tax_ID FROM number_generator WHERE description='application_number';
       INSERT INTO users (name, username, email,  password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, `rank`,sector)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, Tax_ID, in_rank,in_sector); 
        UPDATE number_generator SET `next_code` = Tax_ID WHERE description='application_number';
        
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
        SELECT * FROM `tax_payers` u WHERE   u.phone LIKE CONCAT('%', in_id, '%') OR u.email LIKE CONCAT('%', in_id, '%'); 
    ELSEIF query_type = 'select-tax-payer' THEN
        SELECT * FROM `tax_payers` u 
        WHERE u.taxID LIKE CONCAT('%', in_id, '%') 
        OR u.nin LIKE CONCAT('%', in_id, '%') 
        OR u.org_tin  LIKE CONCAT('%', in_id, '%')   
        OR u.email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_email  LIKE CONCAT('%', in_id, '%')  
        OR u.office_phone  LIKE CONCAT('%', in_id, '%')  
        OR u.phone  LIKE CONCAT('%', in_id, '%'); 
    ELSEIF query_type = 'add-account' THEN
        INSERT INTO `tax_payers`(user_id, `name`, `username`, `email`, `office_email`, `role`, `bvn`, `tin`,`org_tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `office_phone`, `state`, `lga`, `ward`, `address`, `office_address`) 
		VALUES (in_id, in_name, in_username, in_email, in_office_email, in_role, in_bvn, in_tin,  in_org_tin, in_tax_id, in_org_name, in_rc, in_account_type, in_phone,  in_office_phone, in_state, in_lga, in_ward, in_address,in_office_address);
    ELSEIF query_type = 'select-tax-payers' THEN
        IF in_account_type IS NOT NULL AND in_account_type !='' THEN
            SELECT COUNT(*) INTO @total_rows   FROM `tax_payers` WHERE account_type=in_account_type LIMIT in_offset, in_limit ;
            SELECT  x.*,  @total_rows as total_rows    FROM `tax_payers` x  WHERE x.account_type=in_account_type LIMIT in_offset, in_limit ;
        ELSE
            SELECT COUNT(*) INTO @total_rows   FROM `tax_payers` LIMIT in_offset, in_limit ;
           
            SELECT  x.*,  @total_rows as total_rows  FROM `tax_payers` x LIMIT in_offset, in_limit;
        END IF;
    END IF;
END $$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS selectTransactions $$
CREATE PROCEDURE `selectTransactions`(IN `query_type` VARCHAR(50), IN `in_from` VARCHAR(20), IN `in_to` VARCHAR(20), IN `in_mda_code` VARCHAR(50), IN `in_sector` VARCHAR(50) )
BEGIN  
  IF query_type='sector' THEN 
    IF in_sector IS NOT NULL  THEN
        IF  in_mda_code IS NOT NULL THEN 
            SELECT  COALESCE(SUM(tt.dr), 0) AS total_amt, tt.sector
                FROM tax_transactions AS tt
                WHERE  FIND_IN_SET(tt.sector, in_sector) > 0
                AND tt.status IN ('paid', 'success')
                AND tt.mda_code = in_mda_code
                AND DATE(tt.dateSettled) BETWEEN in_from AND in_to
                GROUP BY sector;
        ELSE
            SELECT  COALESCE(SUM(tt.dr), 0) AS total_amt, tt.sector
                FROM tax_transactions AS tt
                WHERE  FIND_IN_SET(tt.sector, in_sector) > 0
                AND tt.status IN ('paid', 'success')
                AND DATE(tt.dateSettled) BETWEEN in_from AND in_to
                GROUP BY sector;
        END IF;
    ELSE
        SELECT
            all_sectors.sector,
            COALESCE(SUM(tt.dr), 0) AS total_amt
        FROM (
            SELECT DISTINCT sector
            FROM taxes
        ) AS all_sectors
        LEFT JOIN tax_transactions AS tt
            ON all_sectors.sector = tt.sector
            AND tt.status IN ('paid', 'success')
            AND DATE(tt.created_at) BETWEEN in_from AND in_to
        GROUP BY all_sectors.sector;
    END IF;
    
  ELSEIF query_type='mda' THEN
    SELECT SUM(dr) AS total_amt, sector,mda_name FROM tax_transactions WHERE status = 'paid' AND date(created_at) BETWEEN in_from and in_to GROUP BY sector, mda_name;
    
    ELSEIF query_type = 'get_revenue' THEN
        SELECT SUM(dr) as total_amt, description, mda_name,rev_code FROM `tax_transactions` WHERE  status IN ('paid','success') AND date(created_at) BETWEEN in_from and in_to GROUP BY rev_code;
    
    ELSEIF query_type = 'top_50' THEN
        SELECT * FROM `tax_transactions`  WHERE status IN ('paid','success') AND date(created_at) BETWEEN in_from and in_to ORDER BY `tax_transactions`.`dr` DESC LIMIT 50;
    
  END IF;
END $$
DELIMITER ;


ALTER TABLE `taxes` ADD `budget_code` INT(12) NULL DEFAULT NULL AFTER `id`;
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '323');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '324');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010101' WHERE (`id` = '325');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010101' WHERE (`id` = '326');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010101' WHERE (`id` = '327');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010101' WHERE (`id` = '328');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010104' WHERE (`id` = '330');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010104' WHERE (`id` = '331');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010104' WHERE (`id` = '332');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010104' WHERE (`id` = '333');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010302' WHERE (`id` = '335');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010303' WHERE (`id` = '336');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010304' WHERE (`id` = '337');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010305' WHERE (`id` = '338');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010306' WHERE (`id` = '339');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010307' WHERE (`id` = '340');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010312' WHERE (`id` = '342');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010308' WHERE (`id` = '341');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '344');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '345');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '346');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '347');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010603' WHERE (`id` = '348');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010301' WHERE (`id` = '349');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12020455' WHERE (`id` = '350');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010310' WHERE (`id` = '4380');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010104' WHERE (`id` = '4382');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010306' WHERE (`id` = '4383');
UPDATE `kirmasDB`.`taxes` SET `budget_code` = '12010314' WHERE (`id` = '5187');


DELIMITER $$
DROP PROCEDURE IF EXISTS HandleTaxTransaction $$
CREATE PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_tracking_status` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE)
BEGIN
IF p_query_type = 'insert_payment' THEN
    -- Insert a payment transaction
    INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        invoice_status,
        tracking_status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val
    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_invoice_status,
        p_tracking_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
  ELSEIF p_query_type = 'paid_invoice' THEN
         SELECT x.*, 
     x.phone AS payer_phone
FROM tax_transactions x
WHERE x.reference_number = p_reference_number  AND  `status` in ("success","paid") and logId is not null;

  ELSEIF p_query_type = 'view_payment' THEN
    -- View payment transaction
    SELECT * FROM tax_transactions WHERE reference_number = p_reference_number;
  ELSEIF p_query_type = 'insert_invoice' THEN
    -- Insert an invoice transaction
       INSERT INTO tax_transactions (
        user_id,
        item_code,
        mda_name,
        mda_code,
        rev_code,
        description,
        nin_id,
        tin,
        agent_id,
        tax_payer,
        phone,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        invoice_status,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to,
        mda_var,
        mda_val

    ) VALUES (
        p_user_id,
        p_item_code,
        p_mda_name,
        p_mda_code,
        p_rev_code,
        p_description,
        p_nin_id,
        p_tin,
        p_agent_id,
        p_tax_payer,
        p_phone,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_invoice_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date,
        p_mda_var,
        p_mda_val
    );
   ELSEIF p_query_type = 'check_balance' THEN
    -- Query user's balance based on their user_id
    SELECT SUM(CASE WHEN transaction_type = 'payment' THEN cr ELSE -dr END) AS balance
    FROM tax_transactions
    WHERE user_id = p_user_id;
 ELSEIF p_query_type = 'view_payer_ledger' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr 
        FROM tax_transactions y 
        WHERE y.user_id = p_user_id  
        GROUP BY y.reference_number;
    END IF;
 ELSEIF p_query_type = 'view_agent_history' THEN
    -- View payer's ledger for invoice transactions
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr  

        FROM tax_transactions y 
        WHERE y.agent_id = p_agent_id
            AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
            (
                SELECT SUM(x.dr - x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS balance,
            (
                SELECT SUM(x.dr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS dr ,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS cr 
        FROM tax_transactions y 
        WHERE y.agent = p_agent_id 
        GROUP BY y.reference_number;
    END IF;
  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
    
ELSEIF p_query_type = 'view_invoice' THEN
 SELECT x.*, 
       x.phone AS payer_phone
    FROM tax_transactions x
    WHERE x.reference_number = p_reference_number;
    
    ELSEIF p_query_type = 'pending_invoice' THEN
   
    IF p_tracking_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number AND interswitch_ref_no IS NOT NULL  LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.status = p_status;
    ELSEIF p_invoice_status IS NOT NULL AND (p_status IS NULL OR p_status = '') THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number  AND  interswitch_ref_no IS NOT NULL LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status;
    END IF;
    
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS kigra_taxes $$
CREATE PROCEDURE `kigra_taxes`(
  IN `query_type` VARCHAR(100), 
IN `in_id` INT, 
IN `in_tax_code` VARCHAR(100), 
IN `in_economic_code` VARCHAR(100), 
IN `in_tax_parent_code` VARCHAR(100), 
IN `in_description` VARCHAR(100), 
IN `in_tax_fee` VARCHAR(10), 
IN `in_sector` VARCHAR(100), 
IN `in_input_type` VARCHAR(50), 
IN `in_uom` VARCHAR(50), 
IN `in_is_department` VARCHAR(50), 
IN `in_department` VARCHAR(50), 
IN `in_mda_name` VARCHAR(50), 
IN `in_mda_code` VARCHAR(50))
BEGIN
  IF query_type='create-tax' THEN   
    IF in_tax_fee = '' THEN 
      SET in_tax_fee = NULL;
    END IF;
    INSERT INTO `taxes` (`tax_code`, `economic_code`, `tax_parent_code`, `title`, `tax_fee`,`sector`,`default`,`uom`, `is_department`, `department`, `mda_name`, `mda_code`) 
    VALUES (in_tax_code,in_economic_code,in_tax_parent_code,in_description,in_tax_fee,in_sector,in_input_type,in_uom, in_is_department, in_department, in_mda_name, in_mda_code);
    
    ELSEIF query_type = 'update-tax' THEN
    -- Update an existing tax record based on the provided parameters.
    UPDATE `taxes` x
    SET
      x.`tax_code` = IFNULL(in_tax_code, x.`tax_code`),
      x.`tax_parent_code` = IFNULL(in_tax_parent_code, x.`tax_parent_code`),
      x.`economic_code` = IFNULL(in_economic_code, x.`economic_code`),
      x.`title` = IFNULL(in_description, x.`title`),
      x.`tax_fee` = IFNULL(in_tax_fee, x.`tax_fee`),
      x.`uom` = IFNULL(in_uom, x.`uom`),
      x.`default` = IFNULL(in_tax_fee, x.`default`),
      x.`sector` = IFNULL(in_sector, x.`sector`)
    WHERE
      x.`id` = in_id;
     ELSEIF query_type = 'delete'  THEN
     DELETE FROM taxes WHERE  `id` = in_id;
      
    ELSEIF query_type = 'select-all'  THEN
SELECT * FROM `taxes` x WHERE x.sector=in_sector;
    ELSEIF query_type = 'select-sector-taxes'  THEN
      SELECT * FROM `taxes` x WHERE  x.sector=in_sector ;

    ELSEIF query_type = 'select-heads'  THEN
        SELECT * FROM `taxes` x WHERE   x.title!=''
        AND (x.tax_fee IS NULL  OR  x.tax_fee=''  )  AND x.sector=in_sector;
    ELSEIF query_type = 'select-main'  THEN

      SELECT * FROM `taxes` x WHERE   x.tax_parent_code !='' AND x.title='' AND x.sector=in_sector;
  ELSEIF query_type = 'select-sub'  THEN

    IF in_sector IS NOT NULL THEN

    IF in_tax_parent_code IS NOT NULL THEN
      SELECT * FROM `taxes` x WHERE x.sector=in_sector AND x.tax_fee IS NOT NULL AND  x.tax_parent_code =  in_tax_parent_code;
  ELSE
    SELECT * FROM `taxes` x WHERE x.sector=in_sector AND x.tax_fee IS NOT NULL;
  END IF;
  ELSE
        SELECT * FROM `taxes` x WHERE x.tax_parent_code =  in_tax_parent_code AND x.tax_fee IS NOT NULL;
END IF;
ELSEIF query_type = 'selected-sub'  THEN
IF in_sector IS NOT NULL THEN
  SELECT * FROM `taxes` x WHERE x.tax_parent_code =  in_tax_parent_code AND x.sector=in_sector AND x.tax_fee IS NOT NULL AND x.tax_fee!='';
ELSE
      SELECT * FROM `taxes` x WHERE x.tax_parent_code =  in_tax_parent_code;
END IF;
ELSEIF query_type = 'select' AND in_tax_code IS NOT NULL OR in_tax_parent_code IS NOT NULL THEN
      IF in_tax_parent_code IS NOT NULL THEN
SELECT * FROM `taxes` WHERE tax_parent_code =in_tax_parent_code AND  title IS NOT NULL;
ELSEIF in_tax_code IS NOT NULL THEN
SELECT * FROM `taxes` WHERE tax_code =in_tax_code;

END IF;
ELSEIF  query_type='select-mdas' THEN
SELECT * FROM mdas_1;
ELSEIF query_type='select-healthcares' THEN
SELECT * FROM `state_health_facilities` WHERE ownership_code =1 LIMIT 50;
ELSEIF query_type='select-high-institutions' THEN
SELECT * FROM `educ_institutions`;
ELSEIF query_type='presumptive' THEN
	SELECT * FROM presumptive_taxes;
END IF;
END $$
DELIMITER ;