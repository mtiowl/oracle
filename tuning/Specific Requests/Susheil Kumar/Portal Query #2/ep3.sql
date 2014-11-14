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
  	ACCOUNT.TX_SERVICE_LINE_1
  FROM	PVIEW.ACCOUNT
  WHERE account.KY_SUPPLIER = 'EPLUSGAS'
    AND ky_enroll > 0
/

@utlxpls.sql