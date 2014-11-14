spool ep.out
REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;
alter session set optimizer_index_cost_adj = 50;


DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT a.KY_CALL_LOG_ID
       --,dbms_lob.substr(E.TX_CALL_LOG_MSG, 4000, 1) AS COMMENTS
       ,D.ky_supplier AS SUPPLIER
       ,D.tx_customer_name AS customer_name
       ,a.tx_billing_number AS ACCOUNT_NUMBER
       ,TRUNC(A.ts_added) DATE_FIRST_ENTERED
       ,DECODE(A.cd_follow_up_status, 'OPEN_FL_REQ', 'OPEN') AS OPEN_OR_CLOSED
       ,C.tx_call_type AS CALL_TIER_SUMMARY
       ,a.ts_modified
       ,ROUND(SYSDATE - a.ts_modified - ((
             TRUNC (NEXT_DAY (SYSDATE, 'SAT') - NEXT_DAY (a.ts_modified - 1, 'SAT')) / 7) + (
             TRUNC (NEXT_DAY (SYSDATE, 'SUN') - NEXT_DAY (a.ts_modified - 1, 'SUN')) / 7 )) + 1
           ) -1 AS NUM_BUSINESS_DAYS_ELAPSED
       --,P_CIS_CALL_LOG.Get_Call_Rep_name(a.id_user_guid) AS AGENT_NAME
       ,a.id_user_guid
       ,TRUNC(A.ts_modified) AS DATE_LAST_UPDATED
       --,a.ts_modified
FROM CIS_CL_HEADER A
    ,CIS_CL_CALL_TYPES C
    ,PVIEW.ACCOUNT D
    --,CIS_CL_MESSAGES E
WHERE trunc(A.ts_modified) BETWEEN  TRUNC(sysdate) - 90 AND TRUNC(sysdate) 
  AND a.cd_follow_up_status <> 'CLOSED'
  AND a.ky_call_log_id = c.ky_call_log_id
  --AND a.ky_call_log_id = E.ky_call_log_id
  AND A.KY_ENROLL = D.KY_ENROLL
--ORDER BY NUM_BUSINESS_DAYS_ELAPSED DESC
/

SELECT plan_table_output FROM TABLE(dbms_xplan.display(null, 'MTI', 'ALL') )
/
--@utlxpls.sql

spool off
set linesize 100