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




DROP   PROCEDURE IF EXISTS `HandleTaxTransaction`;

DELIMITER $$
CREATE  PROCEDURE `HandleTaxTransaction`(
  IN `p_query_type` ENUM('view_payment','insert_payment','insert_invoice','check_balance','verify_payment','view_payer_ledger'), 
  IN `p_user_id` INT, 
  IN `p_agent_id` INT, 
  IN `p_org_code` VARCHAR(20), 
  IN `p_rev_code` VARCHAR(20), 
  IN `p_description` VARCHAR(200), 
  IN `p_cr` DECIMAL(10,2), 
  IN `p_dr` DECIMAL(10,2), 
  IN `p_transaction_date` DATE, 
  IN `p_transaction_type` ENUM('payment','invoice'), 
  IN `p_status` VARCHAR(20), 
  IN `p_reference_number` VARCHAR(50))
BEGIN
  IF p_query_type = 'insert_payment' THEN
    -- Insert a payment transaction
    INSERT INTO tax_transactions (
      user_id,
      org_code,
      description,
      cr,
      dr,
      transaction_date,
      transaction_type,
      status,
      reference_number
    ) VALUES (
      p_user_id,
      p_org_code,
      p_description,
      p_cr,
      p_dr,
      p_transaction_date,
      p_transaction_type,
      p_status,
      p_reference_number
    );
ELSEIF  p_query_type = 'view_payment' THEN
SELECT * from tax_transactions x WHERE x.reference_number = p_reference_number;
   
  ELSEIF p_query_type = 'insert_invoice' THEN
    -- Insert an invoice transaction
    INSERT INTO tax_transactions (
      user_id,
      org_code,
      description,
      cr,
      dr,
      transaction_date,
      transaction_type,
      status,
      reference_number
    ) VALUES (
      p_user_id,
      p_org_code,
      p_description,
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
ELSE
    -- Invalid query_type
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid query_type';
  END IF;
END$$
DELIMITER ;