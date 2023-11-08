ALTER TABLE `tax_transactions` ADD `qty` INT(4) NOT NULL DEFAULT '1' AFTER `dr`;

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
    -- AND dateSettled >='2023-10-01' 
    AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
    AND   sector = p_sector
    GROUP BY   mda_name
    HAVING total > 0;

    ELSEIF p_query_type ='sectorly-reports' THEN

    SELECT sector, sum(cr) AS total 
        from tax_transactions 
        WHERE status IN ('paid','success') 
        AND sector = p_sector
    -- AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
    GROUP BY sector;
    ELSEIF p_query_type ='bankly-reports' THEN

    SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
    -- AND dateSettled >='2023-10-01'  
    AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
    AND   sector = p_sector
    GROUP BY bank_name;

    ELSEIF p_query_type ='monthly-reports' THEN

    SELECT MONTH(transaction_date) AS month, 
    
    YEAR(transaction_date) AS year,
    sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
    -- AND dateSettled >='2023-10-01'  
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
    -- AND   y.dateSettled >='2023-10-01'
    AND   y.sector = p_sector
    GROUP BY y.reference_number;
    END IF;
ELSE IF p_mda_code IS NOT NULL  AND p_mda_code !='' THEN
 IF p_query_type = 'total-revenue' THEN

    SELECT SUM(cr) as total  FROM tax_transactions WHERE status IN ('paid','success') 
    AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
    # AND   dateSettled >='2023-10-01'
    AND   mda_code = p_mda_code;
    ELSEIF p_query_type ='all-mda-reports' THEN

        SELECT mda_name, SUM(cr) as total
        FROM tax_transactions
        WHERE  status IN ('paid', 'success')
        -- AND dateSettled >='2023-10-01' 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        GROUP BY   mda_name
        HAVING total > 0;

    ELSEIF p_query_type ='bankly-reports' THEN

        SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        AND   mda_code = p_mda_code
        GROUP BY bank_name;

    ELSEIF p_query_type ='sectorly-reports' THEN

        SELECT sector, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        AND   mda_code = p_mda_code
        GROUP BY sector;

    ELSEIF p_query_type ='monthly-reports' THEN

        SELECT MONTH(transaction_date) AS month, 
        
        YEAR(transaction_date) AS year,
        sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
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
        -- AND   y.dateSettled >='2023-10-01'
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
        -- AND dateSettled >='2023-10-01' 
        AND DATE(transaction_date) BETWEEN p_start_date and p_end_date
        GROUP BY   mda_name
        HAVING total > 0;

    ELSEIF p_query_type ='bankly-reports' THEN

        SELECT bank_name, sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
        AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        GROUP BY bank_name;

    ELSEIF p_query_type ='sectorly-reports' THEN

        SELECT sector, sum(cr) AS total 
            from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
            AND DATE(transaction_date)  BETWEEN p_start_date and p_end_date
        GROUP BY sector;

    ELSEIF p_query_type ='monthly-reports' THEN

        SELECT MONTH(transaction_date) AS month, 
        
        YEAR(transaction_date) AS year,
        sum(cr) AS total 
        from tax_transactions WHERE status IN ('paid','success') 
        -- AND dateSettled >='2023-10-01'  
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