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
SELECT DBMS_XMLGEN.GETXML('
         SELECT  CIS_CL_HEADER.KY_CALL_LOG_ID
                ,P_CIS_CALL_LOG.get_call_rep_name(CIS_CL_HEADER.ID_USER_GUID) AS NOTATED_BY
                ,CIS_CL_HEADER.TX_BILLING_NUMBER
                ,CIS_CL_HEADER.TX_FIRST_NAME
                ,CIS_CL_HEADER.TX_LAST_NAME
                ,CIS_CL_HEADER.TX_EMAIL
                ,CIS_CL_HEADER.TX_PHONE_NO
                ,CIS_CL_HEADER.TX_POSITION
                ,CIS_CL_HEADER.CD_FOLLOW_UP_STATUS
                ,CIS_CL_HEADER.CD_FOLLOW_UP_HOURS
                ,CIS_CL_HEADER.FL_CRITICAL_COMMENT
                ,CIS_CL_HEADER.TS_CRITICAL_COMMENT_EXPIRE
                ,CIS_CL_HEADER.KY_NOTATE_TYPE
                ,CIS_CL_HEADER.TS_ADDED
                ,CIS_CL_HEADER.TS_MODIFIED
                ,CIS_CL_MESSAGES.TX_CALL_LOG_MSG
                ,CURSOR(SELECT   CIS_CL_CALL_TYPES.TX_CALL_TYPE
                          FROM   CIS_CL_CALL_TYPES
                          WHERE   CIS_CL_CALL_TYPES.KY_CALL_LOG_ID = CIS_CL_HEADER.KY_CALL_LOG_ID) CALL_TYPES
                ,CURSOR(SELECT CIS_CL_LINKED_ACCOUNTS.TX_BILLING_NUMBER
                              ,CIS_CL_LINKED_ACCOUNTS.FL_ACTIVE
                          FROM   CIS_CL_LINKED_ACCOUNTS
                          WHERE   CIS_CL_LINKED_ACCOUNTS.KY_CALL_LOG_ID = CIS_CL_HEADER.KY_CALL_LOG_ID) LINKED_ACCOUNTS
           FROM CIS_CL_HEADER
               ,CIS_CL_MESSAGES
           WHERE   CIS_CL_MESSAGES.KY_CALL_LOG_ID = CIS_CL_HEADER.KY_CALL_LOG_ID
             AND   (    CIS_CL_HEADER.CD_STATUS IS NULL
                     OR CIS_CL_HEADER.CD_STATUS <> ''D'')
             AND   CIS_CL_HEADER.KY_CALL_LOG_ID in (SELECT   CIS_CL_LINKED_ACCOUNTS.KY_CALL_LOG_ID
                                                      FROM   CIS_CL_LINKED_ACCOUNTS
                                                     WHERE   CIS_CL_LINKED_ACCOUNTS.tx_billing_number = '|| :B1 ||')
          ORDER BY CIS_CL_HEADER.TS_ADDED DESC', 0) ADDL_CALL_LOGS FROM DUAL
/

@utlxpls.sql