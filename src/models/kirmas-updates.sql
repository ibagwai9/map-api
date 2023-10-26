ALTER TABLE `tax_transactions` ADD `qty` INT(4) NOT NULL DEFAULT '1' AFTER `dr`;



DELIMITER $$
DROP PROCEDURE  IF EXISTS `mda_queries` $$
CREATE  PROCEDURE `mda_queries`(
    IN `p_query_type` VARCHAR(50), 
    IN `p_mda_code` VARCHAR(15), 
    IN `p_start_date` DATE, 
    IN `p_end_date` DATE
    )
BEGIN 

IF p_query_type = 'total-revenue' THEN

  SELECT SUM(tx.cr) as total  FROM tax_transactions tx WHERE tx.status IN ('paid','success') AND DATE(tx.transaction_date) BETWEEN p_start_date and p_end_date
  AND   x.dateSettled >='2023-10-01';

ELSEIF p_query_type ='all-mda-reports' THEN

SELECT x.mda_name, x.mda_code, 
  COALESCE(SUM(tx.cr), 0) as total
FROM taxes x
INNER JOIN tax_transactions tx
ON x.mda_code = tx.mda_code AND tx.status IN ('paid', 'success')
WHERE x.mda_name IS NOT NULL AND tx.dateSettled IS NOT NULL  AND DATE(tx.transaction_date) BETWEEN p_start_date and p_end_date
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
        WHERE    y.mda_code = p_mda_code  and  y.status IN ('paid','success') AND DATE(y.transaction_date) BETWEEN DATE(p_start_date) AND DATE(p_end_date)
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
END$$
DELIMITER ;
