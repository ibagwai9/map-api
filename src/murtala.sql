ALTER TABLE `users` CHANGE `accessTo` `accessTo` VARCHAR(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;
UPDATE `users` SET `accessTo` = 'MDA Reports, Tax Payers, Tax Setup, Tax Admins, TAX,  NON TAX, VEHICLES, LAND, LGA' WHERE `users`.`role` ="admin"
DROP PROCEDURE `kigra_taxes`;
DELIMITER $$
CREATE  PROCEDURE `kigra_taxes`(IN `query_type` VARCHAR(100), IN `in_id` INT, IN `in_tax_code` VARCHAR(100), IN `in_tax_parent_code` VARCHAR(100), IN `in_description` VARCHAR(100), IN `in_tax_fee` VARCHAR(10), IN `in_sector` VARCHAR(100), IN `in_input_type` VARCHAR(50))
BEGIN
  IF query_type='create' THEN    
    INSERT INTO `taxes` (`tax_code`, `tax_parent_code`, `title`, `tax_fee`,`sector`,default_input) VALUES
  (in_tax_code,in_tax_parent_code,in_description,in_tax_fee,in_sector,in_input_type) ;
    ELSEIF query_type = 'update-tax' THEN
    -- Update an existing tax record based on the provided parameters.
    UPDATE `taxes`
    SET
      `tax_code` = IFNULL(in_tax_code, `tax_code`),
      `tax_parent_code` = IFNULL(in_tax_parent_code, `tax_parent_code`),
      `title` = IFNULL(in_description, `title`),
      `tax_fee` = IFNULL(in_tax_fee, `tax_fee`),
      `sector` = IFNULL(in_sector, `sector`),
      default_input= IFNULL(in_input_type, `default_input`)
    WHERE
      `id` = in_id;
     ELSEIF query_type = 'delete'  THEN
     DELETE FROM taxes WHERE  `id` = in_id;
      
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
END IF;
END$$
DELIMITER ;

