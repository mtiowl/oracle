
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
SELECT er.ky_enroll, acct.tx_customer_name, er.tx_client_account, er.tx_tracking_id,er.tx_contract_name, rownum
 FROM enroll er, account acct
 WHERE er.KY_SUPPLIER = 'TESI'
   AND er.ky_enroll = acct.ky_enroll 
/

spool ep.out
@utlxpls.sql
spool off
