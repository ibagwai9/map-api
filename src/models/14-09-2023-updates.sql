
DROP  PROCEDURE IF EXISTS `kigra_taxes`;
DELIMITER $$
CREATE  PROCEDURE `kigra_taxes`(IN `query_type` VARCHAR(100), IN `in_id` INT, IN `in_tax_code` VARCHAR(100), IN `in_tax_parent_code` VARCHAR(100), IN `in_description` VARCHAR(100), IN `in_tax_fee` VARCHAR(10), IN `in_sector` VARCHAR(100))
BEGIN
  IF query_type='create' THEN    
    INSERT INTO `taxes` (`tax_code`, `tax_parent_code`, `title`, `tax_fee`,`sector`) VALUES
    (in_tax_code,in_tax_parent_code,in_description,in_tax_fee,in_sector) ;
 
    ELSEIF query_type = 'select-all'  THEN
SELECT * FROM `taxes` x WHERE x.sector=in_sector;
    ELSEIF query_type = 'select-sector-taxes'  THEN
      SELECT * FROM `taxes` x WHERE  x.sector=in_sector AND tax_fee>0;

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
    ELSEIF query_type = 'update-tax' THEN
    -- Update an existing tax record based on the provided parameters.
    UPDATE `taxes`
    SET
      `tax_code` = IFNULL(in_tax_code, `tax_code`),
      `tax_parent_code` = IFNULL(in_tax_parent_code, `tax_parent_code`),
      `title` = IFNULL(in_description, `title`),
      `tax_fee` = IFNULL(in_tax_fee, `tax_fee`),
      `sector` = IFNULL(in_sector, `sector`)
    WHERE
      `id` = in_id;

END IF;

END$$
DELIMITER ;
ALTER TABLE users
MODIFY COLUMN `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `username` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `email` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `office_email` VARCHAR(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `password` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `role` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `bvn` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `tin` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `nin` VARCHAR(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `org_tin` VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `taxID` VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `org_name` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `rc` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `account_type` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `phone` VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `office_phone` VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `state` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `lga` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `address` VARCHAR(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `office_address` VARCHAR(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
MODIFY COLUMN `accessTo` VARCHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;


DROP  PROCEDURE `user_accounts`;
DELIMITER $$
CREATE PROCEDURE `user_accounts`(IN `in_query_type` VARCHAR(20), IN `in_id` INT, IN `in_name` VARCHAR(255), IN `in_username` VARCHAR(255), IN `in_email` VARCHAR(255), IN `in_office_email` VARCHAR(255), IN `in_password` VARCHAR(255), IN `in_role` VARCHAR(255), IN `in_bvn` VARCHAR(11), IN `in_tin` VARCHAR(11), IN `in_org_tin` VARCHAR(11), IN `in_org_name` VARCHAR(200), IN `in_rc` VARCHAR(11), IN `in_account_type` VARCHAR(20), IN `in_phone` VARCHAR(15), IN `in_office_phone` VARCHAR(15), IN `in_state` VARCHAR(20), IN `in_lga` VARCHAR(100), IN `in_address` VARCHAR(200), IN `in_office_address` VARCHAR(200), IN `in_accessTo` VARCHAR(11))
BEGIN
  
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
ELSEIF in_query_type = 'select-user' THEN
 SELECT * FROM `users` u WHERE u.taxID LIKE CONCAT('%', in_tin, '%') OR u.nin LIKE CONCAT('%', in_tin, '%') OR u.org_tin OR u. email LIKE CONCAT('%', in_tin, '%') OR u.office_email LIKE CONCAT('%', in_tin, '%') OR u.office_phone LIKE CONCAT('%', in_tin, '%') OR u.phone LIKE CONCAT('%', in_tin, '%'); 

    END IF;
END$$
DELIMITER ;