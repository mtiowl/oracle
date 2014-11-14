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
  SELECT beh.ts_created
    FROM bill_email_history_hdr beh
        ,bill_hdr bh
        ,account a
    WHERE beh.fl_processed = 'N'
      AND beh.ky_bill = bh.ky_bill
      AND bh.dt_bill_due > SYSDATE
      AND a.ky_enroll = bh.ky_enroll
      --AND bh.dt_bill_due = SYSDATE
/

@utlxpls.sql