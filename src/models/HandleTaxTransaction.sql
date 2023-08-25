DROP TABLE IF EXISTS `tax_transactions`;

CREATE TABLE `tax_transactions` (
 `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
 `user_id` int(11) NOT NULL,
 `org_code` int(11) NOT NULL,
 `rev_code` varchar(20) NOT NULL,
 `description` varchar(300) NOT NULL,
 `nin_id` int(10) NOT NULL,
 `agent_id` int(9) DEFAULT NULL,
 `org_name` varchar(300) DEFAULT NULL,
 `paid_by` varchar(50) NOT NULL,
 `confirmed_by` varchar(50) NOT NULL,
 `confirmed_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
 `payer_acct_no` varchar(10) NOT NULL,
 `payer_bank_name` int(11) NOT NULL,
 `cr` decimal(10,2) NOT NULL,
 `dr` decimal(10,2) NOT NULL,
 `transaction_date` date NOT NULL,
 `transaction_type` enum('payment','invoice') NOT NULL,
 `status` varchar(20) NOT NULL,
 `reference_number` varchar(50) DEFAULT NULL,
 `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
 `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
 PRIMARY KEY (`transaction_id`),
 KEY `user_id` (`user_id`),
 KEY `sector_id` (`org_code`),
 KEY `tax_type` (`description`),
 KEY `transaction_type` (`transaction_type`),
 KEY `transaction_date` (`transaction_date`),
 CONSTRAINT `tax_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
);


DROP PROCEDURE `HandleTaxTransaction`;

DELIMITER $$
CREATE PROCEDURE `HandleTaxTransaction`(IN `p_query_type` ENUM('view_payment','insert_payment','insert_invoice','check_balance','view_payer_ledger','approve_payment'), IN `p_user_id` VARCHAR(9), IN `p_agent_id` VARCHAR(9), IN `p_org_code` VARCHAR(30), IN `p_rev_code` VARCHAR(20), IN `p_description` VARCHAR(300), IN `p_nin_id` VARCHAR(12), IN `p_org_name` VARCHAR(300), IN `p_paid_by` VARCHAR(50), IN `p_confirmed_by` VARCHAR(50), IN `p_payer_acct_no` VARCHAR(10), IN `p_payer_bank_name` VARCHAR(50), IN `p_cr` DECIMAL(10,2), IN `p_dr` DECIMAL(10,2), IN `p_transaction_date` DATE, IN `p_transaction_type` ENUM('payment','invoice'), IN `p_status` VARCHAR(20), IN `p_reference_number` VARCHAR(50)) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
  IF p_query_type = 'insert_payment' THEN
    -- Insert a payment transaction
    INSERT INTO tax_transactions (
      user_id,
      org_code,
      rev_code,
      description,
      nin_id,
      agent_id,
      org_name,
      paid_by,
      confirmed_by,
      payer_acct_no,
      payer_bank_name,
      cr,
      dr,
      transaction_date,
      transaction_type,
      status,
      reference_number
    ) VALUES (
      p_user_id,
      p_org_code,
      p_rev_code,
      p_description,
      p_nin_id,
      p_agent_id,
      p_org_name,
      p_paid_by,
      p_confirmed_by,
      p_payer_acct_no,
      p_payer_bank_name,
      p_cr,
      p_dr,
      p_transaction_date,
      p_transaction_type,
      p_status,
      p_reference_number
    );
  ELSEIF p_query_type = 'view_payment' THEN
    -- View payment transaction
    SELECT * FROM tax_transactions WHERE reference_number = p_reference_number;
  ELSEIF p_query_type = 'insert_invoice' THEN
    -- Insert an invoice transaction
    INSERT INTO tax_transactions (
      user_id,
      org_code,
      rev_code,
      description,
      nin_id,
      agent_id,
      org_name,
      paid_by,
      confirmed_by,
      payer_acct_no,
      payer_bank_name,
      cr,
      dr,
      transaction_date,
      transaction_type,
      status,
      reference_number
    ) VALUES (
      p_user_id,
      p_org_code,
      p_rev_code,
      p_description,
      p_nin_id,
      p_agent_id,
      p_org_name,
      p_paid_by,
      p_confirmed_by,
      p_payer_acct_no,
      p_payer_bank_name,
      p_cr,
      p_dr,
      p_transaction_date,
      p_transaction_type,
      p_status,
      p_reference_number
    );
  ELSEIF p_query_type = 'check_balance' THEN
    -- Query user's balance based on their user_id
    SELECT SUM(CASE WHEN transaction_type = 'payment' THEN cr ELSE -dr END) AS balance
    FROM tax_transactions
    WHERE user_id = p_user_id;
  ELSEIF p_query_type = 'view_payer_ledger' THEN
    -- View payer's ledger for invoice transactions
    SELECT 
      y.*,
      (SELECT SUM(x.dr - x.cr) FROM tax_transactions x WHERE x.reference_number = y.reference_number) AS balance 
    FROM 
      tax_transactions y 
    WHERE 
      y.transaction_type = 'invoice'
      AND y.user_id = p_user_id  
    GROUP BY 
      y.reference_number;
  ELSEIF p_query_type = 'approve_payment' THEN
    -- Approve a payment transaction
    UPDATE tax_transactions
    SET status = 'approved', confirmed_by = p_confirmed_by, confirmed_on = NOW()
    WHERE reference_number = p_reference_number AND status = 'pending';
  ELSE
    -- Invalid query_type
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid query_type';
  END IF;
END $$
DELIMITER ;

ALTER TABLE `tax_transactions` CHANGE `nin_id` `nin_id` VARCHAR(12) NULL DEFAULT NULL;
ALTER TABLE `tax_transactions` CHANGE `payer_bank_name` `payer_bank_name` VARCHAR(30) NOT NULL;
ALTER TABLE `tax_transactions` CHANGE `org_code` `org_code` VARCHAR(50) NOT NULL;
ALTER TABLE `users` ADD `office_email` VARCHAR(64) NULL DEFAULT NULL AFTER `email`;ß
ALTER TABLE `users` CHANGE `company_name` `org_name` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;
ALTER TABLE `users` ADD `office_phone` VARCHAR(15) NULL DEFAULT NULL AFTER `phone`;
ALTER TABLE `users` ADD `org_tin` VARCHAR(15) NULL DEFAULT NULL AFTER `tin`;

DROP PROCEDURE `user_accounts`;
DELIMITER $$
CREATE  PROCEDURE `user_accounts`(
    IN `in_query_type` VARCHAR(20), 
    IN `in_id` INT, 
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
    IN `in_accessTo` VARCHAR(11)
  ) NOT DETERMINISTIC CONTAINS SQL SQL SECURITY DEFINER BEGIN
  
    CALL in_number_generator('select', NULL, 'application_number', NULL,@Tax_ID);

    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role, bvn, tin, org_tin, org_name, rc, account_type, phone, state, lga, address, office_address, accessTo, TaxID)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_bvn, in_tin, in_org_tin, in_org_name, in_rc, in_account_type, in_phone, in_state, in_lga, in_address, in_office_address, in_accessTo, @Tax_ID);
        
        CALL in_number_generator('update', NULL, 'application_number', @Tax_ID,@void);

    ELSEIF in_query_type = 'update' THEN
        UPDATE users
        SET name = in_name, username = in_username, email = in_email, password = in_password, role = in_role, bvn = in_bvn, tin = in_org_tin,  tin = in_org_tin, org_name = in_org_name, rc = in_rc, account_type = in_account_type, phone = in_phone, state = in_state, lga = in_lga, address = in_address, office_address = in_office_address, accessTo = in_accessTo
        WHERE id = in_id;
    ELSEIF in_query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
    END IF;
END $$

UPDATE taxes SET tax_fee = REPLACE(tax_fee, ',', '');
UPDATE taxes SET tax_fee = NULL WHERE tax_fee='';
ALTER TABLE `taxes` CHANGE `tax_fee` `tax_fee` DECIMAL(10,2) DEFAULT NULL; 