ALTER TABLE `tax_transactions` ADD `mda_var` VARCHAR(50) NULL DEFAULT NULL AFTER `tax_station`, ADD `mda_val` VARCHAR(50) NULL DEFAULT NULL AFTER `mda_var`;

ALTER TABLE `presumptive_taxes` ADD `mda_name` VARCHAR(100) NULL DEFAULT NULL AFTER `medium`, ADD `mda_code` VARCHAR(30) NULL DEFAULT NULL AFTER `mda_name`, ADD `sector` VARCHAR(30) NULL DEFAULT NULL AFTER `mda_code`;

 UPDATE `presumptive_taxes` SET `sector` = 'TAX', mda_name='Kano State Internal Revenue Services', mda_code='022000800100';
 
DELIMITER $$
DROP PROCEDURE IF EXISTS `kigra_taxes`$$
CREATE PROCEDURE `kigra_taxes`(
  IN `query_type` VARCHAR(100), 
  IN `in_id` INT, 
  IN `in_tax_code` VARCHAR(100), 
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
    INSERT INTO `taxes` (`tax_code`, `tax_parent_code`, `title`, `tax_fee`,`sector`,`default`,`uom`, `is_department`, `department`, `mda_name`, `mda_code`) 
    VALUES (in_tax_code,in_tax_parent_code,in_description,in_tax_fee,in_sector,in_input_type,in_uom, in_is_department, in_department, in_mda_name, in_mda_code);
    
    ELSEIF query_type = 'update-tax' THEN
    -- Update an existing tax record based on the provided parameters.
    UPDATE `taxes` x
    SET
      x.`tax_code` = IFNULL(in_tax_code, x.`tax_code`),
      x.`tax_parent_code` = IFNULL(in_tax_parent_code, x.`tax_parent_code`),
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
AND x.tax_fee IS NULL  AND x.sector=in_sector;
    ELSEIF query_type = 'select-main'  THEN

      SELECT * FROM `taxes` x WHERE   x.tax_parent_code !='' AND x.title='' AND x.sector=in_sector;
   ELSEIF query_type = 'select-sub'  THEN

      IF in_sector IS NOT NULL THEN
  SELECT * FROM `taxes` x WHERE x.sector=in_sector AND x.tax_fee IS NOT NULL;
ELSE
      SELECT * FROM `taxes` x WHERE x.tax_parent_code =  in_tax_parent_code;
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
END$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS HandleTaxTransaction $$
CREATE PROCEDURE `HandleTaxTransaction`(
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
IN `p_amount` DECIMAL(20,2), 
IN `p_transaction_date` DATE, 
IN `p_transaction_type` ENUM('payment','invoice','transaction'), 
IN `p_status` VARCHAR(20), 
IN `p_ipis_no` VARCHAR(20), 
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
        p_end_date,
        p_mda_var,
        p_mda_val
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
  SELECT * FROM tax_transactions x WHERE x.reference_number  = p_reference_number;
ELSE
  -- Invalid query_type
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Invalid query_type';
END IF;
END $$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF  EXISTS `mda_queries`$$

CREATE  PROCEDURE `mda_queries`(IN `p_query_type` VARCHAR(50), IN `p_mda_code` VARCHAR(15), IN `p_start_date` DATE, IN `p_end_date` DATE) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN 
  IF p_query_type ='all' THEN

  	SELECT x.mda_name, x.mda_code FROM `taxes` x WHERE x.mda_name IS NOT NULL GROUP BY x.mda_name;
  ELSEIF p_query_type ='all-mda-reports' THEN

SELECT x.mda_name, x.mda_code, 
  COALESCE(SUM(tx.cr), 0) as total
FROM taxes x
INNER JOIN tax_transactions tx
ON x.mda_code = tx.mda_code AND tx.status IN ('paid', 'success')
WHERE x.mda_name IS NOT NULL 
GROUP BY x.mda_name, x.mda_code
HAVING total > 0;

ELSEIF p_query_type = 'mda-transactions' THEN
SELECT 
            y.*,
            (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS total
        FROM tax_transactions y 
        WHERE    y.status IN ('paid','success') AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
        GROUP BY y.reference_number;
    ELSE
        SELECT 
            y.*,
          (
                SELECT SUM(x.cr)
                FROM tax_transactions x
                WHERE x.reference_number = y.reference_number
            ) AS total
        FROM tax_transactions y 
        WHERE y.mda_code = p_mda_code  and y.status IN ('paid','success') 
        GROUP BY y.reference_number;  
END IF;
END;

ALTER TABLE `tax_transactions` ADD `branch_address` VARCHAR(50)
 NULL DEFAULT NULL AFTER `payer_bank_name`, ADD `bank_branch` VARCHAR(50)
 NULL DEFAULT NULL AFTER `branch_address`, ADD `bank_cbn_code` VARCHAR(5)
 NULL DEFAULT NULL AFTER `bank_branch`;

 ALTER TABLE `tax_transactions` CHANGE `payer_bank_name` `bank_name` VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;

