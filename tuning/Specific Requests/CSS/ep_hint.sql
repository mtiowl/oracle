spool ep.out
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
--SELECT /*+ USE_HASH("B") */ "KY_BA","DT_BILL","DT_DUE" 
SELECT "KY_BA","DT_BILL","DT_DUE" 
  FROM "BILL_INFO_HDR" "B" 
  WHERE "DT_DUE"<=TO_CHAR(:1-:2,'YYYY-MM-DD') 
/

@utlxpls.sql

spool off