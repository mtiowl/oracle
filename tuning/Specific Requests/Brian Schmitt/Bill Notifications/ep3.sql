REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT          
                DISTINCT bh.dt_bill
                    FROM bill_email_history_hdr beh,
                         bill_hdr bh,
                         ss_account ssa,
                         ACCOUNT a,
                         ss_user_account_access ua
                   WHERE beh.fl_processed = 'N'
                     AND beh.ky_bill = bh.ky_bill
                     AND bh.ky_enroll = ua.ky_enroll
                     AND ua.ky_enroll = ssa.ky_enroll
                     AND ssa.ky_enroll = a.ky_enroll
                     AND bh.ky_supplier = '14'
/

@utlxpls.sql