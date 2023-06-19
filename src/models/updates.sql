update procedure update_budget, tsa_funding
new procedure get_tsa_account



-- xxxxxxxxxxxxxxx
db => finance_fresh

ALTER TABLE `pv_collection` ADD `certificate_no` VARCHAR(15) NOT NULL AFTER `contractor_code`;
ALTER TABLE `contractor_taxes`  ADD `batch_id` VARCHAR(50) NOT NULL  AFTER `tax_id`;
ALTER TABLE `contractor_schedule`  ADD `contractor_bank` VARCHAR(50) NOT NULL  AFTER `contractor_tin`,  ADD `contractor_acc_no` VARCHAR(50) NOT NULL  AFTER `contractor_bank`,  ADD `contractor_acc_sort_code` VARCHAR(50) NOT NULL  AFTER `contractor_acc_no`;

update procedure pv_collection, contractor_schedule, contractor_details
