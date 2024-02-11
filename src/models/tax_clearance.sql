
DROP TABLE IF EXISTS `tax_clearance`;

CREATE TABLE `tax_clearance` (
  `id` int(100) NOT NULL AUTO_INCREMENT,
  `date_issued` date DEFAULT NULL,
  `tin` varchar(100) DEFAULT NULL,
  `tcc_ref` varchar(20) DEFAULT NULL,
  `tax_file_no` varchar(100) DEFAULT NULL,
  `taxID` varchar(100) DEFAULT NULL,
  `tax_payer` varchar(150) DEFAULT NULL,
  `income_source` varchar(100) DEFAULT NULL,
  `year` varchar(100) DEFAULT NULL,
  `first_amount` double(10,2) DEFAULT NULL,
  `second_amount` double(10,2) DEFAULT NULL,
  `third_amount` double(10,2) DEFAULT NULL,
  `first_income` double(10,2) NOT NULL DEFAULT 0.00,
  `second_income` double(10,2) NOT NULL DEFAULT 0.00,
  `third_income` double(10,2) NOT NULL DEFAULT 0.00,
  `first_year` date DEFAULT NULL,
  `second_year` date DEFAULT NULL,
  `third_year` date DEFAULT NULL,
  `status` varchar(100) DEFAULT 'initiated',
  `remark` varchar(100) DEFAULT NULL,
  `raised_by` varchar(100) DEFAULT NULL,
  `raised_at` timestamp NULL DEFAULT NULL,
  `recommendation` varchar(500) DEFAULT NULL,
  `recommended_by` varchar(100) DEFAULT NULL,
  `recommended_at` timestamp NULL DEFAULT NULL,
  `rejection` varchar(500) DEFAULT NULL,
  `approved_by` varchar(100) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `printed` int(4) DEFAULT 0,
  `printed_by` varchar(100) DEFAULT NULL,
  `printed_at` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
);
DROP TABLE IF EXISTS `tax_clearance_logs`;
CREATE TABLE `tax_clearance_logs` (
  `id` int(9) NOT NULL AUTO_INCREMENT,
  `status` varchar(50) DEFAULT NULL,
  `remark` varchar(300) DEFAULT NULL,
  `remark_by` varchar(50) DEFAULT NULL,
  `tax_file_no` varchar(50) DEFAULT NULL,
  `taxID` varchar(50) DEFAULT NULL,
  `tcc_ref` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `tcc_id` int(9) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tcc_id` (`tcc_id`)
) 

DELIMITER $$
DROP  PROCEDURE IF EXISTS `TaxClearance`$$
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
    IN `in_first_income` DOUBLE(10,2), 
    IN `in_second_income` DOUBLE(10,2), 
    IN `in_third_income` DOUBLE(10,2), 
    IN `in_first_year` DATE, 
    IN `in_second_year` DATE, 
    IN `in_third_year` DATE, 
    IN `in_status` VARCHAR(100), 
    IN `in_remark` VARCHAR(100), 
    IN `in_raised_by` VARCHAR(100), 
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
      `tax_payer`,
      `tin`,
      `tcc_ref`,
      `tax_file_no`,
      `taxID`,
      `income_source`,
      `year`,
      `first_amount`,
      `second_amount`,
      `third_amount`,
      `first_income`, 
      `second_income`, 
      `third_income`, 
      `first_year`,
      `second_year`,
      `third_year`,
      `status`,
      `remark`,
      `raised_by`,
      `raised_at`)
    VALUES (
      in_date_issued,
      in_tax_payer,
      in_tin,
      in_tcc_ref,
      in_tax_file_no,
      in_taxID,
      in_income_source,
      in_year,
      in_first_amount,
      in_second_amount,
      in_third_amount,
      in_first_income, 
      in_second_income, 
      in_third_income, 
      in_first_year,
      in_second_year,
      in_third_year,
      'initiated',
      in_remark,
      in_staff_name,
      NOW());

  CALL tax_clearance_logs('create', NULL,'initiated', 'initiated', in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref, LAST_INSERT_ID() );
  
  ELSEIF query_type = 'search' THEN
      SELECT * FROM `tax_clearance` WHERE taxID LIKE CONCAT('%',in_id,'%') OR  tax_payer LIKE CONCAT('%',in_id,'%')  LIMIT in_offset,in_limit;
   ELSEIF query_type = 'print-search' THEN
      SELECT * FROM `tax_clearance` WHERE status='approved' OR printed > 0 AND (taxID LIKE CONCAT('%',in_id,'%') OR  tax_payer LIKE CONCAT('%',in_id,'%')  OR  tax_payer LIKE CONCAT('%',in_tcc_ref,'%') OR  tax_payer LIKE CONCAT('%',in_tax_file_no,'%') )  LIMIT in_offset,in_limit;
  ELSEIF query_type = 'recommendation' THEN
    UPDATE `tax_clearance` SET status= 'recommended', recommendation = in_recommendation, recommended_by = in_staff_name, recommended_at = NOW() WHERE id=in_id;
    CALL tax_clearance_logs('create', NULL,'recommended', in_recommendation, in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref, in_id );
  ELSEIF query_type = 'select' THEN
      SELECT * FROM `tax_clearance` WHERE id=in_id;
  ELSEIF query_type = 'select-status' THEN 
    IF in_from IS NOT NULL AND in_to IS NOT NULL THEN
        SELECT * FROM `tax_clearance` WHERE status = in_status AND DATE(`updated_at`) BETWEEN DATE(in_from) AND DATE(in_to)  LIMIT in_offset,in_limit;
    ELSE 
        SELECT * FROM `tax_clearance` WHERE status = in_status  LIMIT in_offset,in_limit;
    END IF;
ELSEIF query_type = 'get-new-prints' THEN 
    IF in_from IS NOT NULL AND in_to IS NOT NULL THEN
        SELECT * FROM `tax_clearance` WHERE printed <1 AND DATE(`updated_at`) BETWEEN DATE(in_from) AND DATE(in_to)  LIMIT in_offset,in_limit;
    ELSE 
        SELECT * FROM `tax_clearance` WHERE printed <1   LIMIT in_offset, in_limit;
    END IF;
  ELSEIF query_type = 'rejection' THEN
    UPDATE `tax_clearance` SET status= 'rejected', approved_by = in_staff_name, approved_at = NOW() WHERE id=in_id;
    CALL tax_clearance_logs('create', NULL,'rejected', in_rejection, in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref, in_id);
  ELSEIF query_type = 'approval' THEN
    UPDATE `tax_clearance` SET status= 'approved', tcc_ref=in_tcc_ref, approved_by = in_staff_name, approved_at = NOW() WHERE id=in_id;
    UPDATE `tax_clearance_logs` SET tcc_ref=in_tcc_ref WHERE id=in_id;
    CALL tax_clearance_logs('create', NULL,'approved', in_rejection, in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref, in_id);
  ELSEIF query_type = 'update-printed' THEN
    SELECT  (IFNULL(printed,0) +1) INTO print_count FROM tax_clearance WHERE  status='printed' AND  id=in_id; 
    IF print_count > 1 THEN
      UPDATE tax_clearance t SET t.printed = (t.printed+1) WHERE  id=in_id;
      CALL tax_clearance_logs('create', NULL,'Re-printed', 'Re-printed', in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref,in_id);
    ELSE
      UPDATE tax_clearance  SET printed = 1, status='printed', printed_at = DATE(NOW()), printed_by=in_staff_name WHERE  id=in_id;
      CALL tax_clearance_logs('create', NULL,'recommended', 'Printed', in_staff_name, in_tax_file_no, in_taxID,  in_tcc_ref,in_id);
      SELECT * FROM `tax_clearance` WHERE status = 'approved' AND id=in_id;
    END IF;
  
  ELSEIF query_type = 'get-remarks' THEN
    SELECT * FROM tax_clearance_logs WHERE tcc_id =in_id;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
 DROP PROCEDURE IF EXISTS `tax_clearance_logs` $$
CREATE  PROCEDURE `tax_clearance_logs`(IN `query_type` VARCHAR(50), IN `in_id` INT(9), IN `in_status` VARCHAR(50), IN `in_remark` VARCHAR(300), IN `in_remark_by` VARCHAR(50), IN `in_tax_file_no` VARCHAR(50), IN `in_taxID` VARCHAR(50), IN `in_tcc_ref` VARCHAR(20), IN `in_tcc_id` INT(9))
BEGIN 
     IF query_type = 'create'  THEN
     	INSERT INTO `tax_clearance_logs` 
        (
            status,
            remark,
            remark_by,
            tax_file_no,
            taxID,
            tcc_ref,
            tcc_id
        )
        VALUES (
            in_status,
            in_remark,
            in_remark_by,
            in_tax_file_no,
            in_taxID,
            in_tcc_ref,
            in_tcc_id
        );
     ELSEIF query_type = 'select'  THEN
		SELECT * FROM `tax_clearance_logs` WHERE tcc_ref = in_tcc_ref;
     ELSEIF query_type = 'select-by-tcc_id'  THEN
		SELECT * FROM `tax_clearance_logs` WHERE tcc_id = in_tcc_id;
     END IF;
 
 END$$
DELIMITER ;
