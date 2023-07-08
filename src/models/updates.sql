DROP TABLE `users`;
CREATE TABLE `users` (
 `id` int(11) NOT NULL,
 `name` varchar(255) DEFAULT NULL,
 `username` varchar(255) DEFAULT NULL,
 `email` varchar(255) DEFAULT NULL,
 `password` varchar(255) DEFAULT NULL,
 `role` varchar(255) DEFAULT NULL,
 `bvn` varchar(11) DEFAULT NULL,
 `tin` varchar(11) DEFAULT NULL,
 `company_name` varchar(11) DEFAULT NULL,
 `rc` varchar(11) DEFAULT NULL,
 `account_type` varchar(11) DEFAULT NULL,
 `phone` varchar(11) DEFAULT NULL,
 `state` varchar(11) DEFAULT NULL,
 `lga` varchar(11) DEFAULT NULL,
 `address` varchar(11) DEFAULT NULL,
 `accessTo` varchar(11) DEFAULT NULL,
 `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
 `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
);

DELIMETER $$

CREATE PROCEDURE user_accounts(
    IN in_query_type VARCHAR(20),
    IN in_id INT,
    IN in_name VARCHAR(255),
    IN in_username VARCHAR(255),
    IN in_email VARCHAR(255),
    IN in_password VARCHAR(255),
    IN in_role VARCHAR(255),
    IN in_bvn VARCHAR(11),
    IN in_tin VARCHAR(11),
    IN in_company_name VARCHAR(11),
    IN in_rc VARCHAR(11),
    IN in_account_type VARCHAR(11),
    IN in_phone VARCHAR(11),
    IN in_state VARCHAR(11),
    IN in_lga VARCHAR(11),
    IN in_address VARCHAR(11),
    IN in_accessTo VARCHAR(11)
)
BEGIN
    IF in_query_type = 'insert' THEN
        INSERT INTO users (name, username, email, password, role, bvn, tin, company_name, rc, account_type, phone, state, lga, address, accessTo)
        VALUES (in_name, in_username, in_email, in_password, in_role, in_bvn, in_tin, in_company_name, in_rc, in_account_type, in_phone, in_state, in_lga, in_address, in_accessTo);
    ELSEIF in_query_type = 'update' THEN
        UPDATE users
        SET name = in_name, username = in_username, email = in_email, password = in_password, role = in_role, bvn = in_bvn, tin = in_tin, company_name = in_company_name, rc = in_rc, account_type = in_account_type, phone = in_phone, state = in_state, lga = in_lga, address = in_address, accessTo = in_accessTo
        WHERE id = in_id;
    ELSEIF in_query_type = 'delete' THEN
        DELETE FROM users WHERE id = in_id;
    END IF;
END  $$

DROP PROCEDURE `ngf_account_chart`;
DELIMITER $$
CREATE PROCEDURE `ngf_account_chart`(IN `in_query_type` VARCHAR(400), IN `in_parent_code` VARCHAR(400), IN `in_child_code` VARCHAR(400), IN `in_sector` VARCHAR(400)) NOT DETERMINISTIC NO SQL SQL SECURITY DEFINER 
    BEGIN
        IF in_query_type = "tree" THEN
        SELECT  parent_code as  subhead, child_code as  title, segment, id from ngf_account_chart;

        ELSEIF in_query_type='INSERT' THEN
            INSERT INTO ngf_account_chart(parent_code, child_code,segment) VALUES(in_parent_code,in_child_code,in_sector);
        ELSEIF  in_query_type='UPDATE' THEN
            UPDATE ngf_account_chart SET parent_code=in_parent_code,child_code=in_child_code,sector=in_sector  WHERE child_code=in_child_code;
        ELSEIF in_query_type='DELETE' THEN
            DELETE FROM update_budget WHERE in_mda_child_code=mda_child_code;
        ELSEIF in_query_type = "select_by_tree" THEN
            SELECT MAX(child_code) + "1" as child_code FROM ngf_account_chart WHERE parent_code = in_parent_code;
        ELSEIF in_query_type = "select_all_child_code" THEN 
            SELECT mda_child_code, description, amount, mda_parent_code,  concat (description, "(", mda_child_code, ")") as budget FROM update_budget;
        ELSEIF  in_query_type = "select_revenue_mda"  THEN
            SELECT *  FROM `account_chart` WHERE `head` LIKE '01%' ORDER BY `description`;
        END IF 
    END 
$$