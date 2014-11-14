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
SELECT account.TX_SERVICE_LINE_1
      ,account.TX_SERVICE_LINE_2
      ,account.TX_SERVICE_CITY 
      ,account.KY_SERVICE_STATE
      ,account.TX_SERVICE_ZIP
      ,account.TX_MAIL_LINE_1 
      ,account.TX_MAIL_LINE_2
      ,account.TX_MAIL_CITY 
      ,account.KY_MAIL_STATE
      ,account.TX_MAIL_ZIP
      ,account.TX_UTILITY_ACCOUNT
      ,account.KY_SUPPLIER
      ,account.TX_DAY_PHONE_AREA
      ,account.TX_DAY_PHONE
      ,account.TX_CUSTOMER_NAME
      ,account.TX_DOING_BUSINESS_AS
--
	    ,enroll.KY_ACCOUNT_MANAGER
      ,enroll.TX_TRACKING_ID
      ,enroll.KY_ENROLL
      ,enroll.KY_UTILITY_NAME
      ,enroll.TX_CONTRACT_NAME
--
	    ,bill_account.KY_BILLING_STATUS
      ,bill_account.AT_BALANCE
      ,bill_account.TX_BILLING_NUMBER
FROM PVIEW.account account
    ,PVIEW.bill_account bill_account
    ,PVIEW.enroll enroll
WHERE enroll.KY_ENROLL = account.KY_ENROLL 
  AND bill_account.KY_ENROLL = enroll.KY_ENROLL 
  AND enroll.KY_UTILITY_NAME IN ('APSs')
  AND enroll.ky_supplier IN ('EXELON')

/

@utlxpls.sql