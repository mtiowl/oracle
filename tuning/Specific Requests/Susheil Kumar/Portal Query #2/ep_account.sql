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
SELECT acct.tx_service_line_1
  FROM PVIEW.ACCOUNT acct
      ,PVIEW.ENROLL ENROLL 
      ,PVIEW.BILL_ACCOUNT BA
      ,ER_CUSTOMER CUST
  WHERE enroll.ky_enroll = acct.ky_enroll
    AND ba.ky_enroll = acct.ky_enroll
    AND acct.KY_SUPPLIER = 'EPLUSGAS'
    AND enroll.ky_supplier = acct.ky_supplier
    AND ba.ky_supplier = acct.ky_supplier
    AND cust.KY_ER_REF_ID = acct.KY_ENROLL
    AND cust.ky_supplier_id = acct.ky_supplier
    --AND enroll.ky_supplier = 'EPLUSGAS'
    --AND ba.ky_supplier = 'EPLUSGAS'
    --AND acct.KY_ENROLL = 1
/

@utlxpls.sql