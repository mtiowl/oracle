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
SELECT   bh.dt_bill, bh.dt_bill_due, bh.at_bill_account_balance, ssa.ky_ba,
         a.tx_utility_account AS edc_account, a.tx_customer_name,
         ssa.tx_owner_user_id, beh.ts_created
    FROM bill_email_history_hdr beh,
         bill_hdr bh,
         ss_account ssa,
         ACCOUNT a,
         ss_user_account_access ua
   WHERE beh.fl_processed = 'N'
     AND beh.ky_bill = bh.ky_bill
     AND bh.ky_supplier = ssa.ky_supplier
     AND a.ky_supplier = ssa.ky_supplier
     AND a.ky_supplier = bh.ky_supplier
     AND bh.ky_enroll = ua.ky_enroll
     AND ua.ky_enroll = ssa.ky_enroll
     AND ssa.ky_enroll = a.ky_enroll
     AND bh.ky_enroll = a.ky_enroll
     AND bh.ky_enroll = ssa.ky_enroll
     and ua.ky_enroll = ssa.ky_enroll
     AND bh.dt_bill_due > SYSDATE
ORDER BY dt_bill
/

@utlxpls.sql