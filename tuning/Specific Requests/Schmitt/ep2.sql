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
  SELECT a.ky_enroll
    FROM ss_account ssa
         ,ACCOUNT a
         ,bill_hdr bh
   WHERE a.ky_enroll = ssa.ky_enroll
     and bh.ky_enroll = a.ky_enroll
     and bh.dt_bill_due > SYSDATE
/

@utlxpls.sql