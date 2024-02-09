CREATE TABLE `tax_clearance` (
  `id` int(100) NOT NULL AUTO_INCREMENT,
  `date_issued` date DEFAULT NULL,
  `tin` varchar(100) DEFAULT NULL,
  `tcc_ref` varchar(100) DEFAULT NULL,
  `tax_file_no` varchar(100) DEFAULT NULL,
  `taxID` varchar(100) DEFAULT NULL,
  `tax_payer` varchar(150) DEFAULT NULL,
  `income_source` varchar(100) DEFAULT NULL,
  `year` varchar(100) DEFAULT NULL,
  `first_amount` double(10,2) DEFAULT NULL,
  `second_amount` double(10,2) DEFAULT NULL,
  `third_amount` double(10,2) DEFAULT NULL,
  `first_year` date DEFAULT NULL,
  `second_year` date DEFAULT NULL,
  `third_year` date DEFAULT NULL,
  `status` varchar(100) DEFAULT 'initiated',
  `remark` varchar(100) DEFAULT NULL,
  `recommendation` varchar(500) DEFAULT NULL,
  `recommended_by` varchar(100) DEFAULT NULL,
  `rejection` varchar(500) DEFAULT NULL,
  `approved_by` varchar(100) DEFAULT NULL,
  `printed` int(4) DEFAULT NULL,
  `printed_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
);
ALTER TABLE `tax_clearance` ADD `printed_at` DATE NULL DEFAULT NULL AFTER `printed_by`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `TaxClearance` $$
CREATE  PROCEDURE `TaxClearance`(
    IN `query_type` VARCHAR(100), 
    IN `in_id` VARCHAR(100), 
    IN `in_date_issued` DATE, 
    IN `in_tin` VARCHAR(100), 
    IN `in_tcc_ref` VARCHAR(100), 
    IN `in_tax_file_no` VARCHAR(100), 
    IN `in_taxID` VARCHAR(100), 
    IN `in_tax_payer` VARCHAR(150), 
    IN `in_income_source` VARCHAR(100), 
    IN `in_year` VARCHAR(10), 
    IN `in_first_amount` DOUBLE(10,2), 
    IN `in_second_amount` DOUBLE(10,2), 
    IN `in_third_amount` DOUBLE(10,2), 
    IN `in_first_year` DATE, 
    IN `in_second_year` DATE, 
    IN `in_third_year` DATE, 
    IN `in_status` VARCHAR(100), 
    IN `in_remark` VARCHAR(100), 
    IN `in_recommendation` VARCHAR(400), 
    IN `in_recommended_by` VARCHAR(100), 
    IN `in_rejection` VARCHAR(100), 
    IN `in_approved_by` VARCHAR(100), 
    IN `in_printed` INT(2), 
    IN `in_printed_by` VARCHAR(100), 
    IN `in_staff_name` VARCHAR(100), 
    IN `in_from` DATE, 
    IN `in_to` DATE, 
    IN `in_limit` INT(4), 
    IN `in_offset` INT(4)
)
BEGIN
DECLARE print_count, total_prints, total_rows INT;

    IF query_type = 'create' THEN
        INSERT INTO `tax_clearance` (
            `date_issued`,
            `tin`,
            `tcc_ref`,
            `tax_file_no`,
            `taxID`,
            `income_source`,
            `year`,
            `first_amount`,
            `second_amount`,
            `third_amount`,
            `first_year`,
            `second_year`,
            `third_year`,
            `status`,
            `remark`
        )
        VALUES (
            in_date_issued,
            in_tin,
            in_tcc_ref,
            in_tax_file_no,
            in_taxID,
            in_income_source,
            in_year,
            in_first_amount,
            in_second_amount,
            in_third_amount,
            in_first_year,
            in_second_year,
            in_third_year,
            'initiated',
            in_remark
        );
        CALL tax_clearance_logs('create', NULL,'initiated', 'initiated', in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref );
    ELSEIF query_type = 'search' THEN
        SELECT * FROM `tax_clearance` WHERE taxID LIKE CONCAT('%',in_id,'%') OR  tax_payer LIKE CONCAT('%',in_id,'%')  LIMIT in_offset,in_limit;
    ELSEIF query_type = 'recommendation' THEN
        UPDATE `tax_clearance` SET status= 'recommended', recommendation = in_recommendation, recommended_by = in_staff_name WHERE taxID=in_taxID AND tax_file_no = in_tax_file_no;

        CALL tax_clearance_logs('create', NULL,'recommended', in_recommendation, in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref );
    
    ELSEIF query_type = 'select' THEN
        SELECT * FROM `tax_clearance` WHERE taxID=in_taxID AND tax_file_no = in_tax_file_no;
    ELSEIF query_type = 'select-status' THEN 
        IF in_from IS NOT NULL AND in_to IS NOT NULL THEN

            SELECT * FROM `tax_clearance` WHERE status = in_status AND DATE(`updated_at`) BETWEEN DATE(in_from) AND DATE(in_to)  LIMIT in_offset,in_limit;
        ELSE 

            SELECT * FROM `tax_clearance` WHERE status = in_status  LIMIT in_offset,in_limit;
        END IF;
    ELSEIF query_type = 'approval' THEN
        UPDATE `tax_clearance` SET status= 'approved', approved_by = in_staff_name WHERE taxID=in_taxID AND tax_file_no = in_tax_file_no;
        CALL tax_clearance_logs('create', NULL,'approved', in_rejection, in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref );
    
    ELSEIF query_type = 'printing' THEN
        SELECT  (printed +1) INTO print_count FROM tax_clearance WHERE  status='printed' AND taxID=in_taxID AND tax_file_no = in_tax_file_no;
       
        IF print_count > 2 THEN
        	UPDATE tax_clearance t SET t.printed = (t.printed+1) WHERE  taxID=in_taxID AND tax_file_no = in_tax_file_no;
    	ELSE
    		UPDATE tax_clearance t SET t.printed = (t.printed+1), printed_at = DATE(NOW()), printed_by=in_staff_name WHERE  taxID=in_taxID AND tax_file_no = in_tax_file_no;
    	END IF;
         CALL tax_clearance_logs('create', NULL,'recommended', 'Printed', in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref );
    
        SELECT * FROM `tax_clearance` WHERE status = 'approved' AND taxID=in_taxID AND tax_file_no = in_tax_file_no;
    END IF;
END$$
DELIMITER ;