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
  SELECT bh.ky_enroll
    FROM bill_hdr bh
        ,bill_email_history_hdr beh
    WHERE bh.dt_bill_due > SYSDATE
      AND beh.ky_bill = bh.ky_bill
/

@utlxpls.sql