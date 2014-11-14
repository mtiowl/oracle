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
  select ky_ba, dt_period_start, dt_period_end
    from  custpro.cpm_pnd_tran_hdr
    where dt_billed_by_css >= trunc(sysdate-7)
/

@utlxpls.sql