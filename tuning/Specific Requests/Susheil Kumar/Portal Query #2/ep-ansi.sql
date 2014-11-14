REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT 
	ACCOUNT.TX_SERVICE_LINE_1, 
	ACCOUNT.TX_SERVICE_LINE_2, 
	ACCOUNT.TX_SERVICE_CITY, 
	ACCOUNT.KY_SERVICE_STATE, 
	ACCOUNT.TX_SERVICE_ZIP, 
	ACCOUNT.TX_MAIL_LINE_1, 
	ACCOUNT.TX_MAIL_LINE_2, 
	ACCOUNT.TX_MAIL_CITY, 
	ACCOUNT.KY_MAIL_STATE, 
	ACCOUNT.TX_MAIL_ZIP, 
	ACCOUNT.TX_UTILITY_ACCOUNT, 
	BILL_ACCOUNT.TX_BILLING_NUMBER, 
	ENROLL.KY_ENROLL, 
	ENROLL.KY_UTILITY_NAME, 
	ACCOUNT.TX_CUSTOMER_NAME, 
	ENROLL.TX_CONTRACT_NAME, 
	ACCOUNT.TX_DOING_BUSINESS_AS, 
	BILL_ACCOUNT.KY_BILLING_STATUS, 
	BILL_ACCOUNT.AT_BALANCE, 
	ENROLL.KY_SUPPLIER, 
	ACCOUNT.TX_DAY_PHONE_AREA, 
	ACCOUNT.TX_DAY_PHONE, 
	ENROLL.KY_ACCOUNT_MANAGER, 
	ENROLL.TX_TRACKING_ID, 
	ENROLL.TX_CLIENT_ACCOUNT AS TX_CLIENT_ACCTNO
FROM 
	PVIEW.ACCOUNT 
	LEFT JOIN PVIEW.BILL_ACCOUNT bill_account ON (bill_account.ky_enroll = account.ky_enroll AND bill_account.ky_supplier = account.ky_supplier) 
	LEFT JOIN PVIEW.ENROLL ENROLL ON (enroll.ky_enroll = account.ky_enroll AND enroll.ky_supplier = account.ky_supplier) 
WHERE 
	(BILL_ACCOUNT.KY_BILLING_STATUS IN ('02')) AND 
	(ENROLL.KY_SUPPLIER IN ('GEXA')) 
/




















@utlxpls.sql