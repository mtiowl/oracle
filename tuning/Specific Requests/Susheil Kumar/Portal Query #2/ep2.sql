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
SELECT 	ACCOUNT.TX_SERVICE_LINE_1
       ,BILL_ACCOUNT.TX_BILLING_NUMBER
	     ,ENROLL.KY_ENROLL
  FROM	PVIEW.ACCOUNT
  	   ,PVIEW.BILL_ACCOUNT BILL_ACCOUNT
  	   ,PVIEW.ENROLL ENROLL 
     	 --,ER_CUSTOMER CUSTOMER 
  WHERE BILL_ACCOUNT.KY_ENROLL = ACCOUNT.KY_ENROLL
    AND ENROLL.KY_ENROLL = ACCOUNT.KY_ENROLL
    AND bill_account.ky_supplier = enroll.ky_supplier
    AND account.ky_supplier = enroll.ky_supplier
    AND BILL_ACCOUNT.KY_BILLING_STATUS IN ('02')
    AND bill_account.ky_supplier = 'EPLUSGAS'
/

@utlxpls.sql