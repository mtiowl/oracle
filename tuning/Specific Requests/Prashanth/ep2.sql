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
SELECT A.KY_CALL_LOG_ID
       --,a.tx_billing_number AS ACCOUNT_NUMBER
       --,TRUNC(A.ts_added) DATE_FIRST_ENTERED
       --,DECODE(A.cd_follow_up_status, 'OPEN_FL_REQ', 'OPEN') AS OPEN_OR_CLOSED
       --,C.tx_call_type AS CALL_TIER_SUMMARY
       --,ROUND(SYSDATE - a.ts_modified - ((
       --      TRUNC (NEXT_DAY (SYSDATE, 'SAT') - NEXT_DAY (a.ts_modified - 1, 'SAT')) / 7) + (
       --      TRUNC (NEXT_DAY (SYSDATE, 'SUN') - NEXT_DAY (a.ts_modified - 1, 'SUN')) / 7 )) + 1
       --    ) -1 AS NUM_BUSINESS_DAYS_ELAPSED
       --,TRUNC(A.ts_modified) AS DATE_LAST_UPDATED
FROM CIS_CL_HEADER A
WHERE trunc(A.ts_modified) BETWEEN  TRUNC(sysdate)- 90 AND TRUNC(sysdate) 
  AND a.cd_follow_up_status <> 'CLOSED'
--ORDER BY NUM_BUSINESS_DAYS_ELAPSED DESC
/

@utlxpls.sql

spool off
set linesize 100