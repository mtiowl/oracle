REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE cpes.plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT A.SUPPLIER_ID, A.FIRST_NAME , A.LAST_NAME , A.AD_BILL_LN_1, A.AD_BILL_LN_2,A.AD_BILL_CITY, A.AD_BILL_ST, A.AD_BILL_ZIP
     , A.TX_PHN_NO, A.TX_EMAIL_AD, A.UTIL_NO, A.AD_SERV_LN_1, A.AD_SERV_LN_2, A.AD_SERV_CITY, A.AD_SERV_ST, A.AD_SERV_ZIP, A.RATE_ID
     , A.RATE_CLASS, A.ID_PROSPECT , A.STATUS, A.FL_BB , A.BUSINESS_NAME, A.METER_NUMBER 
  FROM CAS_PROSPECT A 
  WHERE UPPER(A.CUST_CODE) = UPPER(:B3 ) 
    AND A.SUPPLIER_ID = :B2 
    AND A.UTIL_CODE = :B1
/

@utlxpls.sql