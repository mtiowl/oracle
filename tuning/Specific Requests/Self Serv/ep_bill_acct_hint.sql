SPOOL ep.out

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
select KY_ENROLL, KY_SUPPLIER
  FROM PVIEW.BILL_ACCOUNT
  WHERE TX_BILLING_NUMBER = '123'
/

@utlxpls.sql

spool off