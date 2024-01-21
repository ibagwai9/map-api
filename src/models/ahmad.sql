CREATE TABLE `reciept_logs` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ref_no` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `remark` varchar(300) NOT NULL,
  `staff_name` varchar(50) NOT NULL,
  `staff_id` int(9) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci


DELIMETER $$
CREATE PROCEDURE `reciept_logs` (
  
IN  `in_query_type` varchar(50)
  `in_id` int(10),
IN  `in_ref_no` varchar(20) ,
IN  `in_status` varchar(20),
IN  `in_remark` varchar(300) ,
IN  `in_staff_name` varchar(50) ,
IN  `in_staff_id` int(9) 
)

DROP PROCEDURE `reciept_logs`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reciept_logs`(IN `query_type` VARCHAR(50), IN `in_id` INT(10), IN `in_ref_no` VARCHAR(20), IN `in_status` VARCHAR(50), IN `in_invoice_status` INT, IN `in_remark` VARCHAR(300), IN `in_staff_name` VARCHAR(50), IN `in_staff_id` INT(9)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN

IF query_type='insert' THEN
UPDATE tax_transactions SET remark = in_remark, invoice_status= in_invoice_status, status= in_status WHERE reference_number = in_ref_no;
  INSERT INTO `reciept_logs`(`id`, `ref_no`,`status`,`invoice_status`,`remark`, `staff_name`, `staff_id`) 
  VALUES (`in_id`,
   `in_ref_no`,
   `in_status`,
   `in_invoice_status`,
   `in_remark`,
   `in_staff_name`,
   `in_staff_id`) ;
END IF;
END

ALTER TABLE `tax_transactions` CHANGE `invoice_status` `invoice_status` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;

DELIMITER $$
drop  PROCEDURE if exists `HandleTaxTransaction`$$
CREATE  PROCEDURE `HandleTaxTransaction`(
    IN `p_query_type` VARCHAR(50), 
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
ELSEIF p_query_type = 'pending_invoice' THEN
SELECT * from tax_transactions where invoice_status= p_invoice_status;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END$$
DELIMITER ;




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
ELSEIF p_query_type = 'pending_invoice' THEN

    IF p_invoice_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT * from tax_transactions where invoice_status= p_invoice_status AND status = p_status;
    ELSEIF p_invoice_status IS NOT NULL AND p_status IS NULL OR p_status = "" THEN
        SELECT * from tax_transactions where invoice_status= p_invoice_status;
    END IF;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END 

DROP PROCEDURE `HandleTaxTransaction`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_invoice_status_a` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
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
        invoice_status_a,
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
        p_invoice_status_a,
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
        invoice_status_a,
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
        p_invoice_status_a,
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
ELSEIF p_query_type = 'pending_invoice' THEN

    IF p_invoice_status_a IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT * from tax_transactions where invoice_status_a= p_invoice_status_a AND status = p_status;
    ELSEIF p_invoice_status_a IS NOT NULL AND p_status IS NULL OR p_status = "" THEN
        SELECT * from tax_transactions where invoice_status_a= p_invoice_status_a;
    END IF;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END

DROP PROCEDURE `reciept_logs`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reciept_logs`(IN `query_type` VARCHAR(30), IN `in_id` INT(10), IN `in_ref_no` VARCHAR(50), IN `in_status` VARCHAR(30), IN `in_invoice_status_a` VARCHAR(50), IN `in_remark` VARCHAR(300), IN `in_staff_name` VARCHAR(30), IN `in_staff_id` VARCHAR(30), IN `in_interswitch_ref` VARCHAR(50), IN `in_logId` VARCHAR(20)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
IF query_type='insert' THEN
UPDATE tax_transactions SET remark = in_remark, invoice_status_a= in_invoice_status_a, interswitch_ref=in_interswitch_ref,logId = in_logId,status= in_status WHERE reference_number = in_ref_no;
INSERT INTO `reciept_logs`( `ref_no`,`status`,`invoice_status_a`,`remark`, `staff_name`, `staff_id`,`logId`)
	VALUES (
   in_ref_no,
   in_status,
   in_invoice_status_a,
   in_remark,
   in_staff_name,
   in_staff_id,
   in_logId
   ) ;
END IF;
END



DROP PROCEDURE `HandleTaxTransaction`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_tracking_status` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
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
ELSEIF p_query_type = 'pending_invoice' THEN

    IF p_tracking_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT * from tax_transactions where tracking_status= p_tracking_status AND status = p_status;
    ELSEIF p_invoice_status IS NOT NULL AND p_status IS NULL OR p_status = "" THEN
        SELECT * from tax_transactions where tracking_status= p_tracking_status;
    END IF;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END



DROP PROCEDURE `reciept_logs`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reciept_logs`(IN `query_type` VARCHAR(30), IN `in_id` INT(10), IN `in_ref_no` VARCHAR(50), IN `in_status` VARCHAR(30), IN `in_invoice_status` VARCHAR(50), IN `in_remark` VARCHAR(300), IN `in_staff_name` VARCHAR(30), IN `in_staff_id` VARCHAR(30), IN `in_interswitch_ref` VARCHAR(50), IN `in_logId` VARCHAR(20)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
IF query_type='insert' THEN
UPDATE tax_transactions SET remark = in_remark, tracking_status= in_invoice_status, interswitch_ref=in_interswitch_ref,logId = in_logId,status= in_status WHERE reference_number = in_ref_no;
INSERT INTO `reciept_logs`( `ref_no`,`status`,`invoice_status`,`remark`, `staff_name`, `staff_id`,`logId`)
	VALUES (
   in_ref_no,
   in_status,
   in_invoice_status,
   in_remark,
   in_staff_name,
   in_staff_id,
   in_logId
   ) ;
END IF;
END




DROP PROCEDURE `reciept_logs`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reciept_logs`(IN `query_type` VARCHAR(30), IN `in_id` INT(10), IN `in_ref_no` VARCHAR(50), IN `in_status` VARCHAR(30), IN `in_invoice_status` VARCHAR(50), IN `in_remark` VARCHAR(300), IN `in_staff_name` VARCHAR(30), IN `in_staff_id` VARCHAR(30), IN `in_interswitch_ref_no` VARCHAR(50), IN `in_logId` VARCHAR(20)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
DECLARE in_logId INT;
SET in_logId = FLOOR(RAND() * 100000000);
IF query_type='insert' THEN
IF in_invoice_status = 'Approved authrization' THEN
UPDATE tax_transactions SET remark = in_remark, tracking_status= in_invoice_status, interswitch_ref=in_interswitch_ref_no,logId = in_logId,status= in_status WHERE reference_number = in_ref_no;
ELSE 
UPDATE tax_transactions SET remark = in_remark, tracking_status= in_invoice_status,logId = in_logId,status= in_status WHERE reference_number = in_ref_no;
END IF;
INSERT INTO `reciept_logs`( `ref_no`,`status`,`invoice_status`,`remark`, `staff_name`, `staff_id`,`interswitch_ref_no`)
	VALUES (
   in_ref_no,
   in_status,
   in_invoice_status,
   in_remark,
   in_staff_name,
   in_staff_id,
   in_interswitch_ref_no
   ) ;
END IF;
END

DROP PROCEDURE `HandleTaxTransaction`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_tracking_status` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN

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
    
    ELSEIF p_query_type = 'pending_invoice' THEN
   
    IF p_tracking_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number AND ref_no IS NOT NULL LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.status = p_status;
    ELSEIF p_invoice_status IS NOT NULL AND (p_status IS NULL OR p_status = '') THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number  AND ref_no IS NOT NULL LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status;
    END IF;
    
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END




DROP PROCEDURE `HandleTaxTransaction`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_tracking_status` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN

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
    
    ELSEIF p_query_type = 'pending_invoice' THEN
   
    IF p_tracking_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number AND ref_no IS NOT NULL LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.status = p_status AND t.reference_number = p_reference_number;
    ELSEIF p_invoice_status IS NOT NULL AND (p_status IS NULL OR p_status = '') THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number  AND ref_no IS NOT NULL LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.reference_number = p_reference_number;
    END IF;
    
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END







DROP PROCEDURE `HandleTaxTransaction`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HandleTaxTransaction`(IN `p_query_type` VARCHAR(50), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_tax_payer` VARCHAR(100), IN `p_phone` VARCHAR(100), IN `p_mda_name` VARCHAR(300), IN `p_mda_code` VARCHAR(50), IN `p_item_code` VARCHAR(50), IN `p_rev_code` VARCHAR(50), IN `p_description` VARCHAR(500), IN `p_nin_id` VARCHAR(12), IN `p_tin` VARCHAR(12), IN `p_amount` DECIMAL(20,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_invoice_status` VARCHAR(50), IN `p_tracking_status` VARCHAR(50), IN `p_reference_number` VARCHAR(50), IN `p_department` VARCHAR(150), IN `p_service_category` VARCHAR(150), IN `p_tax_station` VARCHAR(50), IN `p_sector` VARCHAR(50), IN `p_mda_var` VARCHAR(50), IN `p_mda_val` VARCHAR(50), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN

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
    
    ELSEIF p_query_type = 'pending_invoice' THEN
   
    IF p_tracking_status IS NOT NULL AND p_status IS NOT NULL THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number AND ref_no IS NOT NULL AND ref_no != "" LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.status = p_status AND t.reference_number = p_reference_number;
    ELSEIF p_invoice_status IS NOT NULL AND (p_status IS NULL OR p_status = '') THEN
        SELECT t.*, 
               (SELECT interswitch_ref_no FROM reciept_logs WHERE ref_no = t.reference_number  AND ref_no IS NOT NULL AND ref_no != "" LIMIT 1) AS interswitch_ref_no
        FROM tax_transactions t
        WHERE t.tracking_status = p_tracking_status AND t.reference_number = p_reference_number;
    END IF;
    
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END