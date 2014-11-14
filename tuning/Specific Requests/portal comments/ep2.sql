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
SELECT hdr.ky_call_log_id, accts.ky_linked_account_id
      ,msg.ky_call_log_msg_id, wfg.ky_linked_wfg_id
  FROM cis_cl_header hdr
      ,cis_cl_linked_accounts accts
      ,cis_cl_messages msg
      ,cis_cl_linked_wfg wfg
  WHERE hdr.ky_call_log_id = accts.ky_call_log_id
    AND hdr.ky_call_log_id = msg.ky_call_log_id
    AND hdr.ky_call_log_id = wfg.ky_call_log_id
/

@utlxpls.sql