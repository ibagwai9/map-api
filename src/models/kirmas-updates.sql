DROP PROCEDURE IF EXISTS `print_report`;
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
    DROP PROCEDURE IF EXISTS `print_report` $$
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
	DECLARE print_count INT;
	IF in_query_type = 'print' THEN
        CALL print_logs('insert', in_user_id, in_user_name, in_ref );

        UPDATE tax_transactions t SET t.printed = (t.printed+1), printed_at = DATE(NOW()), printed_by=in_user_name WHERE reference_number=in_ref;
    ELSEIF in_query_type = 'view-logs' THEN
      SELECT p.*, t.description, t.tax_payer, t.dr as amount, t.status, (SELECT x.printed FROM tax_transactions x WHERE x.reference_number = in_ref LIMIT 1) AS printed, t.paymentdate
FROM tax_transactions t
LEFT JOIN print_logs p ON p.ref_no = t.reference_number
WHERE t.dr > 0 AND t.reference_number  = in_ref;
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
        WHERE printed <> 0 and FIND_IN_SET(sector, in_sector) > 0
            AND DATE(y.printed_at) BETWEEN in_from AND in_to AND y.mda_code = in_mda_code
        GROUP BY y.reference_number 
                   LIMIT in_limit
            OFFSET in_offset;
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
        WHERE printed <> 0 and FIND_IN_SET(sector, in_sector) > 0
            AND DATE(y.printed_at) BETWEEN in_from AND in_to
        GROUP BY y.reference_number           
         LIMIT in_limit
            OFFSET in_offset;
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
        WHERE printed <> 0 and  FIND_IN_SET(sector, in_sector) > 0
            AND DATE(y.printed_at) AND printed_by=in_user_id BETWEEN in_from AND in_to
        GROUP BY y.reference_number;
	ELSEIF in_query_type = 'by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0 AND printed_by = in_user_id AND DATE(created_at) BETWEEN in_from AND in_to;
        ELSEIF in_query_type = 'view-summary' THEN 
            SELECT department, sector, SUM(dr) AS total, in_from  AS start_date, in_to AS end_date
            FROM tax_transactions
            WHERE dr > 0
            AND status IN ('paid', 'success')
            AND FIND_IN_SET(sector, in_sector) > 0
            AND DATE(created_at) BETWEEN in_from AND in_to
            GROUP BY department, sector;
    ELSEIF in_query_type = 'view-history' THEN 
        IF in_view ='all' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0   
            LIMIT in_limit
            OFFSET in_offset;
        ELSEIF in_view ='invoice' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND status ='saved' AND  FIND_IN_SET(sector, in_sector) > 0
             LIMIT in_limit
            OFFSET in_offset;
        ELSEIF in_view ='receipt' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND status IN('paid','success')  AND   FIND_IN_SET(sector, in_sector) > 0 AND   DATE(created_at) BETWEEN in_from AND in_to 
             LIMIT in_limit
            OFFSET in_offset;
        END IF;
    ELSEIF in_query_type = 'count-history' THEN  
        IF in_view ='all' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0;          
        ELSEIF in_view ='invoice' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND status ='saved' AND  FIND_IN_SET(sector, in_sector) > 0;
         ELSEIF in_view ='receipt' THEN
            SELECT COUNT(*) AS row_counts FROM tax_transactions WHERE dr>0 AND status IN('paid','success')  AND   FIND_IN_SET(sector, in_sector) > 0 AND   DATE(created_at) BETWEEN in_from AND in_to ;
        END IF;
    END IF;
END $$
DELIMITER ;
