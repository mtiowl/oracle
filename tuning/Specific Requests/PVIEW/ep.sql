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
   SELECT DISTINCT ky_enroll
     FROM PRICING
     WHERE (rtrim(ky_supplier) = 'TESI' OR rtrim(ky_supplier) = 'TESI')
/

@utlxpls.sql