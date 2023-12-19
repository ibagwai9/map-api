DROP PROCEDURE `selectTransactions`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `selectTransactions`(IN `in_from` VARCHAR(20), IN `in_to` VARCHAR(20), IN `query_type` VARCHAR(50))
BEGIN  
  IF query_type='sector' THEN
    SELECT SUM(dr) AS total_amt, sector FROM tax_transactions WHERE status != 'saved' AND date(created_at) BETWEEN in_from and in_to GROUP BY sector;
    
  ELSEIF query_type='mda' THEN
  SELECT SUM(dr) AS total_amt, sector,mda_name FROM tax_transactions WHERE status != 'saved' AND date(created_at) BETWEEN in_from and in_to GROUP BY sector, mda_name;
    
  ELSEIF query_type = 'get_revenue' THEN
   SELECT SUM(dr) as total_amt, description, mda_name,rev_code FROM `tax_transactions` WHERE  status != 'saved' AND date(created_at) BETWEEN in_from and in_to GROUP BY rev_code;
    
     ELSEIF query_type = 'top_50' THEN
  SELECT * FROM `tax_transactions`  WHERE status != 'saved' AND date(created_at) BETWEEN in_from and in_to ORDER BY `tax_transactions`.`dr` DESC LIMIT 50;
    
  END IF;
END$$
DELIMITER ;