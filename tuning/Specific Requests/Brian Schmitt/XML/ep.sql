REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE
set feedback off

alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/



EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
  SELECT --/*+ INDEX_ASC(BEH BILL_EMAIL_HISTORY_HDR_IDX1) */ 
         beh.ky_bill
    FROM BILL_EMAIL_HISTORY_HDR BEH
        ,BILL_HDR BH
        --,SS_ACCOUNT SSA
        --,ACCOUNT A
        ,ss_user_account_access UA
    WHERE BEH.ky_bill = BH.ky_bill
       AND BH.ky_enroll = UA.ky_enroll
       --AND UA.ky_enroll = SSA.ky_enroll
       --AND SSA.ky_enroll = A.ky_enroll
       AND BH.ky_supplier = 'TESI'
       AND BEH.fl_processed = 'N'
     --
     --AND beh.ky_bill = 12365538
     --and BEH.KY_BILL > 0
/
set feedback on
@utlxpls.sql