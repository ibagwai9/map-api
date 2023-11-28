DROP PROCEDURE IF EXISTS `print_report`;
DELIMITER $$
CREATE  PROCEDURE `print_report`(IN `in_query_type` VARCHAR(50), IN `in_ref` VARCHAR(50), IN `in_user_id` VARCHAR(50), IN `in_user_name` VARCHAR(50), IN `in_from` DATE, IN `in_to` DATE, IN `in_mda_code` VARCHAR(50), IN `in_sector` VARCHAR(50), IN `in_view` VARCHAR(50))
BEGIN
	DECLARE print_count INT;
	IF in_query_type = 'print' THEN	
     CALL print_logs('insert', in_user_id, in_user_name, in_ref );
    
		SELECT distinct printed INTO print_count FROM tax_transactions WHERE reference_number=in_ref;
        IF print_count >= 1 THEN
			UPDATE tax_transactions SET printed = printed + 1 WHERE reference_number=in_ref;
        ELSE
			UPDATE tax_transactions SET printed = 1, printed_at = DATE(NOW()), printed_by=in_user_id WHERE reference_number=in_ref;
        END IF;
    ELSEIF in_query_type = 'view-logs' THEN
        SELECT p.*, t.description, t.tax_payer, t.dr as amount
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
        WHERE y.printed <> 0 and  FIND_IN_SET(sector, 'TAX,NON TAX,LAND') > 0
            AND DATE(y.printed_at) AND printed_by=in_user_id BETWEEN in_from AND in_to
        GROUP BY y.reference_number;
	ELSEIF in_query_type = 'by_user' THEN
		SELECT COUNT(distinct reference_number) as counts FROM tax_transactions 
			WHERE printed <> 0 AND printed_by = in_user_id AND DATE(created_at) BETWEEN in_from AND in_to;
	ELSEIF in_query_type = 'view-history' THEN 
        IF in_view ='all' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND  FIND_IN_SET(sector, in_sector) > 0;
        ELSEIF in_view ='invoice' THEN
             SELECT * FROM tax_transactions WHERE dr>0 AND  DATE(created_at) BETWEEN in_from AND in_to AND status ='saved' AND  FIND_IN_SET(sector, in_sector) > 0;
        ELSEIF in_view ='receipt' THEN
            SELECT * FROM tax_transactions WHERE dr>0 AND status ='paid' AND status!='saved' AND   FIND_IN_SET(sector, in_sector) > 0 AND   DATE(created_at) BETWEEN in_from AND in_to ;
        END IF;
	END IF;
END$$
DELIMITER ;