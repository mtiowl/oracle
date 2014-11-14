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
  SELECT hdr.KY_CALL_LOG_ID
                          --,msg.TX_CALL_LOG_MSG
                          ,acct.ky_supplier
                          ,acct.tx_customer_name
                          ,hdr.tx_billing_number
                          ,TRUNC(hdr.ts_added)
                          ,DECODE(hdr.cd_follow_up_status, 'OPEN_FL_REQ', 'OPEN')
                          ,call_type.tx_call_type
                          --,hdr.id_user_guid
                          ,TRUNC(hdr.ts_modified)
     FROM CIS_CL_HEADER hdr
         ,CIS_CL_CALL_TYPES call_type
         ,PVIEW.ACCOUNT acct
         ,CIS_CL_MESSAGES msg
     WHERE trunc(hdr.ts_modified) BETWEEN  TRUNC(sysdate) -90 AND TRUNC(sysdate) 
       AND hdr.cd_follow_up_status <> 'CLOSED'
       AND hdr.ky_call_log_id = call_type.ky_call_log_id
       AND hdr.ky_call_log_id = msg.ky_call_log_id
       AND hdr.KY_ENROLL = acct.KY_ENROLL
/

@utlxpls.sql

spool off
set linesize 100