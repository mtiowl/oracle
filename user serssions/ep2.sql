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
 SELECT min(dt_eff)
  FROM bus_dir_no_instmt
  WHERE ky_ba = 'p_ky_ba'
/

@utlxpls.sql

spool off