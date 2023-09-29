ALTER TABLE `tsa_code` 
ADD COLUMN `balance` INT NULL AFTER `types`;

DELIMITER $$
	CREATE PROCEDURE update_igr (IN in_query_type VARCHAR(50), IN in_account VARCHAR(50),
		IN in_amount INT, IN in_found_source VARCHAR(100))
    BEGIN
		DECLARE tsa_bal INT;
		SELECT balance FROM tsa_code WHERE account_name = 'IGR';
		
		IF in_query_type = 'update' THEN 
			UPDATE tsa_code SET balance = balance + in_amount WHERE account_name = 'IGR';
			INSERT tsa_funding (fund_date, account_name, account_number, balance, fund_source) 
			VALUE (now(), 'IGR', in_account, in_amount, in_found_source);
		END IF;
    END;
$$