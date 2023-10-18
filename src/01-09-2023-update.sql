DELIMITER $$
CREATE  PROCEDURE `user_accounts`(
    
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
    IN `in_rank` VARCHAR(100)
)
BEGIN
  
    DECLARE Tax_ID INT;
        CALL in_number_generator('select', NULL, 'application_number', NULL,@Tax_ID);

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, `rank`, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank, @Tax_ID); 
        
        INSERT INTO `tax_payers`(`name`, `username`, `email`, `role`, `bvn`, `tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `state`, `lga`, `address`) 
        VALUES (in_name,in_username,in_email,in_role,in_bvn,in_org_tin,@Tax_ID,in_org_name,in_rc,in_account_type,in_phone,in_state,in_lga,in_address);
        
        CALL in_number_generator('update', NULL, 'application_number', @Tax_ID,@void);
    ELSEIF in_query_type='create-admin' THEN
       INSERT INTO users (name, username, email, password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department, @Tax_ID); 
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
            office_address = IFNULL(in_office_address, office_address)
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


ALTER TABLE `tax_transactions` CHANGE `amount` `dr` DECIMAL(10,2) NOT NULL;
ALTER TABLE `tax_transactions` ADD `cr` DECIMAL(10,2) NOT NULL DEFAULT '0' AFTER `dr`;

DROP  PROCEDURE IF EXISTS `HandleTaxTransaction`;
DELIMITER $$
CREATE  PROCEDURE `HandleTaxTransaction`(
IN `p_query_type` ENUM('view_invoice','view_payment','insert_payment','insert_invoice','check_balance','view_payer_ledger','approve_payment'), 
IN `p_user_id` VARCHAR(9), 
IN `p_agent_id` VARCHAR(9), 
IN `p_mda_name` VARCHAR(300), 
IN `p_mda_code` VARCHAR(50), 
IN `p_item_code` VARCHAR(50), 
IN `p_rev_code` VARCHAR(50), 
IN `p_description` VARCHAR(500), 
IN `p_nin_id` VARCHAR(12), 
IN `p_tin` VARCHAR(12), 
IN `p_paid_by` VARCHAR(50), 
IN `p_confirmed_by` VARCHAR(50), 
IN `p_payer_acct_no` VARCHAR(10), 
IN `p_payer_bank_name` VARCHAR(50), 
IN `p_amount` DECIMAL(10,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice','transaction'), 
IN `p_status` VARCHAR(20), 
IN `p_reference_number` VARCHAR(50), 
IN `p_department` VARCHAR(150), 
IN `p_service_category` VARCHAR(150), 
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category

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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category
    );
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category

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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category
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

  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
ELSEIF p_query_type = 'view_invoice' THEN
  SELECT * FROM tax_transactions x WHERE x.reference_number  = p_reference_number;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END$$
DELIMITER ;

ALTER TABLE `tax_transactions` CHANGE `org_code` `mda_code` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;

ALTER TABLE `tax_transactions` ADD `mda_name` VARCHAR(150) NULL DEFAULT NULL AFTER `reference_number`;

ALTER TABLE `tax_transactions` ADD `item_code` VARCHAR(100) NULL DEFAULT NULL AFTER `mda_code`;
ALTER TABLE `tax_transactions` ADD `department` VARCHAR(150) NULL DEFAULT NULL AFTER `reference_number`, 
ADD `service_category` VARCHAR(150) NULL DEFAULT NULL AFTER `department`;
ALTER TABLE `tax_transactions` CHANGE `dr` `amount` DECIMAL(10,2) NOT NULL;
ALTER TABLE `tax_transactions` CHANGE `rev_code` `rev_code` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;
ALTER TABLE `tax_transactions` CHANGE `paid_by` `paid_by` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL, CHANGE `confirmed_by` `confirmed_by` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL, CHANGE `payer_acct_no` `payer_acct_no` VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL, CHANGE `payer_bank_name` `payer_bank_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;
ALTER TABLE `tax_transactions` ADD `tin` VARCHAR(12) NULL DEFAULT NULL AFTER `nin_id`;

ALTER TABLE `users` ADD `rank` VARCHAR(12) NULL DEFAULT NULL AFTER `department`;



ALTER TABLE `tax_transactions` ADD `logId` VARCHAR(50) NULL AFTER `service_category`, 
    ADD `paymentdate` DATE NULL DEFAULT NULL AFTER `logId`, ADD `dateSettled` DATE NULL DEFAULT NULL AFTER `paymentdate`;
ALTER TABLE `tax_transactions` ADD `modeOfPayment` VARCHAR(50) NULL DEFAULT NULL AFTER `dateSettled`;

ALTER TABLE `tax_transactions` ADD `interswitch_ref` VARCHAR(60) NULL DEFAULT NULL AFTER `modeOfPayment`;

ALTER TABLE `tax_transactions` ADD `paymentAmount` DECIMAL(10,2) NULL DEFAULT NULL AFTER `cr`;


CREATE TABLE `institution_transactions` (
 `id` varchar(50) NOT NULL,
 `refno` int(11) DEFAULT NULL,
 `institutionName` varchar(255) DEFAULT NULL,
 `institutionCode` varchar(255) DEFAULT NULL,
 `accountNumber` varchar(20) DEFAULT NULL,
 `datetime` datetime DEFAULT NULL,
 `amount` decimal(10,2) DEFAULT NULL,
 `narration` text DEFAULT NULL,
 `anyOtherData` text DEFAULT NULL,
 `payerName` varchar(255) DEFAULT NULL,
 `phone` varchar(15) DEFAULT NULL,
 PRIMARY KEY (`id`)
);


DROP PROCEDURE IF EXISTS PROCEDURE `institution_transactions`;
DELIMITER $$
CREATE  PROCEDURE `institution_transactions`(
    IN `query_type` VARCHAR(100),
    IN `in_id` VARCHAR(100),
    IN `in_refno` VARCHAR(50),
    IN `in_institutionName` VARCHAR(255),
    IN `in_institutionCode` VARCHAR(255),
    IN `in_accountNumber` VARCHAR(20),
    IN `in_datetime` DATETIME,
    IN `in_amount` DECIMAL(10,2),
    IN `in_narration` VARCHAR(250),
    IN `in_anyOtherData` VARCHAR(250),
    IN `in_payerName` VARCHAR(50),
    IN `in_phone` VARCHAR(15),
    IN `start_date` VARCHAR(15),
    IN `end_date` VARCHAR(15)
)
BEGIN 
    IF query_type = 'insert' THEN
        -- Check if a record with the given ID exists
        SET @id_exists = (SELECT COUNT(*) FROM institution_transactions WHERE id = in_id);
        
        IF @id_exists = 0 THEN
            -- Insert the record if the ID does not exist
            INSERT INTO institution_transactions (
                id,
                refno,
                institutionName,
                institutionCode,
                accountNumber,
                datetime,
                amount,
                narration,
                anyOtherData,
                payerName,
                phone
            )
            VALUES (
                in_id,
                in_refno,
                in_institutionName,
                in_institutionCode,
                in_accountNumber,
                in_datetime,
                in_amount,
                in_narration,
                in_anyOtherData,
                in_payerName,
                in_phone
            );
        ELSE
            -- Handle the case when the ID already exists (e.g., you can raise an error)
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Record with ID already exists.';
        END IF;
    ELSEIF query_type = 'select-by-code' THEN
        SELECT * FROM institution_transactions WHERE institutionCode = in_institutionCode AND DATE(`datetime`) BETWEEN start_date AND end_date;
    ELSEIF query_type = 'select-by-phone' THEN
        SELECT * FROM institution_transactions WHERE phone = in_phone AND DATE(`datetime`) BETWEEN start_date AND end_date;
    END IF;
END$$
DELIMITER ;

UPDATE taxes SET mda_name='Kano State Internal Revenue Services', mda_code='022000800100' WHERE sector='TAX';

ALTER TABLE `taxes` CHANGE `is_department` `department` VARCHAR(150) NULL DEFAULT NULL;

ALTER TABLE `tax_transactions` ADD `sector` VARCHAR(50) NULL DEFAULT NULL AFTER `interswitch_ref`;


DROP PROCEDURE IF EXISTS `HandleTaxTransaction`;

DELIMITER $$
CREATE  PROCEDURE `HandleTaxTransaction`(
IN `p_query_type` ENUM('view_invoice','view_payment','insert_payment','insert_invoice','check_balance','view_payer_ledger','approve_payment'), 
IN `p_user_id` VARCHAR(9), 
IN `p_agent_id` VARCHAR(9), 
IN `p_mda_name` VARCHAR(300), 
IN `p_mda_code` VARCHAR(50), 
IN `p_item_code` VARCHAR(50), 
IN `p_rev_code` VARCHAR(50), 
IN `p_description` VARCHAR(500), 
IN `p_nin_id` VARCHAR(12), 
IN `p_tin` VARCHAR(12), 
IN `p_paid_by` VARCHAR(50), 
IN `p_confirmed_by` VARCHAR(50), 
IN `p_payer_acct_no` VARCHAR(10), 
IN `p_payer_bank_name` VARCHAR(50), 
IN `p_amount` DECIMAL(10,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice','transaction'), 
IN `p_status` VARCHAR(20), 
IN `p_reference_number` VARCHAR(50), 
IN `p_department` VARCHAR(150), 
IN `p_service_category` VARCHAR(150), 
IN `p_tax_station` VARCHAR(50), 
IN `p_sector` VARCHAR(50), 
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category,
        sector

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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_sector
    );
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        reference_number,
        department, 
        service_category,
        sector
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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_reference_number,
        p_department, 
        p_service_category,
        p_sector
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

  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
ELSEIF p_query_type = 'view_invoice' THEN
  SELECT * FROM tax_transactions x WHERE x.reference_number  = p_reference_number;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END$$
DELIMITER ;

ALTER TABLE `tax_transactions` ADD `date_from` DATE NULL DEFAULT NULL AFTER `sector`,
ADD `date_to` DATE NULL DEFAULT NULL AFTER `date_from`;

--- 11/10/2023

DROP PROCEDURE IF EXISTS `HandleTaxTransaction`;
DELIMITER $$
CREATE  PROCEDURE `HandleTaxTransaction`(
IN `p_query_type` ENUM('view_invoice','view_payment','insert_payment','insert_invoice','check_balance','view_payer_ledger','view_agent_history','approve_payment'), 
IN `p_user_id` VARCHAR(9), 
IN `p_agent_id` VARCHAR(9), 
IN `p_tax_payer` VARCHAR(100), 
IN `p_mda_name` VARCHAR(300), 
IN `p_mda_code` VARCHAR(50), 
IN `p_item_code` VARCHAR(50), 
IN `p_rev_code` VARCHAR(50), 
IN `p_description` VARCHAR(500), 
IN `p_nin_id` VARCHAR(12), 
IN `p_tin` VARCHAR(12), 
IN `p_paid_by` VARCHAR(50), 
IN `p_confirmed_by` VARCHAR(50), 
IN `p_payer_acct_no` VARCHAR(10), 
IN `p_payer_bank_name` VARCHAR(50), 
IN `p_amount` DECIMAL(10,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice','transaction'), 
IN `p_status` VARCHAR(20), 
IN `p_ipis_no` VARCHAR(20), 
IN `p_reference_number` VARCHAR(50), 
IN `p_department` VARCHAR(150), 
IN `p_service_category` VARCHAR(150), 
IN `p_tax_station` VARCHAR(50), 
IN `p_sector` VARCHAR(50), 
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        ipis_no,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to

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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        p_amount,
        0,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_ipis_no,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date
    );
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
        paid_by,
        confirmed_by,
        payer_acct_no,
        payer_bank_name,
        cr,
        dr,
        transaction_date,
        transaction_type,
        status,
        ipis_no,
        reference_number,
        department, 
        service_category,
        tax_station,
        sector,
        date_from,
        date_to

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
        p_paid_by,
        p_confirmed_by,
        p_payer_acct_no,
        p_payer_bank_name,
        0,
        p_amount,
        p_transaction_date,
        p_transaction_type,
        p_status,
        p_ipis_no,
        p_reference_number,
        p_department, 
        p_service_category,
        p_tax_station,
        p_sector,
        p_start_date,
        p_end_date
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
  SELECT * FROM tax_transactions x WHERE x.reference_number  = p_reference_number;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END$$
DELIMITER ;


ALTER TABLE `finance`.`tax_transactions` DROP FOREIGN KEY `tax_transactions_ibfk_1`;

ALTER TABLE  `tax_transactions`
ADD CONSTRAINT `tax_transactions_ibfk_1` FOREIGN KEY (`taxID`) 
REFERENCES `tax_payers` (`taxID`);


ALTER TABLE `tax_payers` ADD UNIQUE(`taxID`);

ALTER TABLE `users` ADD UNIQUE(`taxID`);


ALTER TABLE `users` CHANGE `user_status` `status` VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;

DROP PROCEDURE IF EXISTS `user_accounts`;

DELIMITER $$
CREATE  PROCEDURE `user_accounts` (
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
IN `in_status` VARCHAR(20))
BEGIN
  
    DECLARE Tax_ID, ins_user_id INT DEFAULT NULL;
    
    DECLARE reord_exists INT;   

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role,account_type, phone, accessTo, mda_name, mda_code, department, `rank`,`status` TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_account_type, in_phone, in_accessTo, in_mda_name, in_mda_code, in_department,in_rank,in_status @Tax_ID); 
        SET ins_user_id = LAST_INSERT_ID();
        
       IF in_account_type = 'individual' OR in_account_type = 'org' THEN
    
    IF in_account_type = 'org' THEN
        SELECT COUNT(*) INTO reord_exists FROM tax_payers WHERE org_name = in_org_name;
        
        IF reord_exists > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Organization name already exists, please reset your password';
        END IF;
    ELSE
        SELECT COUNT(*) INTO reord_exists FROM tax_payers WHERE org_email = in_org_email;
        
        IF reord_exists > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Organization email already exists, please reset your password';
        ELSE
            SELECT COUNT(*) INTO reord_exists FROM tax_payers WHERE email = in_email;
            
            IF reord_exists > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Contact email already exists, please reset your password';
            ELSE
                SELECT COUNT(*) INTO reord_exists FROM tax_payers WHERE phone = in_phone;
                
                IF reord_exists > 0 THEN
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Contact phone already exists, please reset your password';
                END IF;
            END IF;
        END IF;
    END IF;

    CALL in_number_generator('select', NULL, 'application_number', NULL, @Tax_ID);

    INSERT INTO `tax_payers`(`name`, `username`, `email`, `role`, `bvn`, `tin`, `taxID`, `org_name`, `rc`, `account_type`, `phone`, `state`, `lga`, `address`) 
    VALUES (in_name, in_username, in_email, in_role, in_bvn, in_org_tin, @Tax_ID, in_org_name, in_rc, in_account_type, in_phone, in_state, in_lga, in_address);

    CALL in_number_generator('update', NULL, 'application_number', @Tax_ID, @void);
    UPDATE users SET taxID = @Tax_ID WHERE id = ins_user_id;
END IF;

    ELSEIF in_query_type='create-admin' THEN
       INSERT INTO users (name, username, email, password, role, account_type, phone,  accessTo, mda_name, mda_code, department, TaxID, `rank`)
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
           `rank` = IFNULL(in_rank, `rank`)  
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

ALTER TABLE `tax_transactions` ADD `ipis_no` VARCHAR(12) NULL DEFAULT NULL AFTER `status`;

ALTER TABLE `tax_transactions` ADD INDEX(`reference_number`);



ALTER TABLE `tax_transactions` CHANGE `tax_station` `tax_station` VARCHAR(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;

ALTER TABLE `tax_transactions` ADD `tax_payer` VARCHAR(150) NULL DEFAULT NULL AFTER `user_id`;

UPDATE `tax_transactions` tx
SET tx.`tax_payer` = (
    SELECT CASE
        WHEN t.account_type = 'org' THEN t.org_name
        ELSE t.name
    END
    FROM tax_payers t
    WHERE t.taxID = tx.`user_id`
);
