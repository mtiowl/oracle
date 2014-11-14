spool bulk.out
SET SERVEROUTPUT ON SIZE 1000000
set timing off


-- ************************************************************************
--   Creating new objects in the databaes to help us fetch and process
--   records a little faster
-- ************************************************************************

prompt dropping objects
drop type cis_report;
-- Base types
drop type cis_report_record;

prompt recreating the CIS_REPORT_RECORD object (record)
create or replace type cis_report_record as object 
     (ky_call_log_id   NUMBER
     --,all_comments     CLOB
     --,comments         VARCHAR2(4000)
     ,ky_supplier      VARCHAR2(100)
     ,tx_customer_name VARCHAR2(100)
     ,account_number   VARCHAR2(100)
     ,DATE_FIRST_ENTERED DATE
     ,OPEN_OR_CLOSED     VARCHAR2(100)
     ,CALL_TIER_SUMMARY VARCHAR2(100)
     ,modified_date     DATE
     ,NUM_BUSINESS_DAYS_ELAPSED NUMBER
     ,user_guid         char(36)
     --,AGENT_NAME                VARCHAR2(100)
     ,DATE_LAST_UPDATED         DATE
     )
/ 
show error

prompt recreating the CIS_REPORT object (array)
create or replace type cis_report as table of cis_report_record
/
show error

prompt running the sample PL/SQL
set timing on
-- ************************************************************************
--   The following uses the new objects created above
-- ************************************************************************
DECLARE

  l_temp         cis_report := cis_report();
  l_results      cis_report := cis_report();
  j              NUMBER;
  
BEGIN
  dbms_output.put_line ('Start: '||to_char(sysdate, 'HH24:MI:SS')); 
  
  SELECT cis_report_record(a.KY_CALL_LOG_ID
                          ,D.ky_supplier 
                          ,D.tx_customer_name 
                          ,a.tx_billing_number
                          ,TRUNC(A.ts_added)
                          ,DECODE(A.cd_follow_up_status, 'OPEN_FL_REQ', 'OPEN')
                          ,C.tx_call_type
                          ,a.ts_modified
                          ,ROUND(SYSDATE - a.ts_modified - ((
                               TRUNC (NEXT_DAY (SYSDATE, 'SAT') - NEXT_DAY (a.ts_modified - 1, 'SAT')) / 7) + (
                               TRUNC (NEXT_DAY (SYSDATE, 'SUN') - NEXT_DAY (a.ts_modified - 1, 'SUN')) / 7 )) + 1
                             ) -1 
                          ,a.id_user_guid
                          ,TRUNC(A.ts_modified) )
  BULK COLLECT INTO l_temp
  FROM CIS_CL_HEADER A
      ,CIS_CL_CALL_TYPES C
      ,PVIEW.ACCOUNT D
  WHERE trunc(A.ts_modified) BETWEEN  TRUNC(sysdate) - 90 AND TRUNC(sysdate) 
    AND a.cd_follow_up_status <> 'CLOSED'
    AND a.ky_call_log_id = c.ky_call_log_id
    AND A.KY_ENROLL = D.KY_ENROLL
    ;

  dbms_output.put_line ('After firt select: '||to_char(sysdate, 'HH24:MI:SS')||'   Record count: '||l_temp.count);
  
  FOR rec IN (SELECT data.KY_CALL_LOG_ID
                    ,dbms_lob.substr(msg.TX_CALL_LOG_MSG, 4000, 1) comments
                    ,ky_supplier
                    ,tx_customer_name
                    ,account_number
                    ,date_first_entered
                    ,OPEN_OR_CLOSED
                    ,CALL_TIER_SUMMARY
                    ,modified_date
                    ,user_guid
                    ,NUM_BUSINESS_DAYS_ELAPSED
                    ,P_CIS_CALL_LOG.Get_Call_Rep_name(user_guid) agent_name
                    ,DATE_LAST_UPDATED
               FROM TABLE (CAST (l_temp AS cis_report)) data
                  ,cis_cl_messages msg
               WHERE data.ky_call_log_id = msg.ky_call_log_id) LOOP
 
      dbms_output.put_line(rec.ky_call_log_id||' - '||rec.ky_supplier||' - '||rec.agent_name||' - '||rec.date_last_updated||' - '||rec.user_guid||' - '||rec.agent_name);
      j := j + 1;
  
   END LOOP;


  dbms_output.put_line ('after second select: '||to_char(sysdate, 'HH24:MI:SS'));
  dbms_output.put_line (l_temp.count);
  
       
EXCEPTION

  WHEN others THEN
     dbms_output.put_line (sqlerrm);
END;
/

spool off
set timing off
