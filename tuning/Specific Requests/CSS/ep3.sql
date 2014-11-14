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
SELECT ky_prem_no, TS_KY_PWQ
  FROM serv_ord 
  WHERE KY_BA = :gas_ky_ba and cd_so_stat = '50'
/

@utlxpls.sql

spool off