SPOOL ep.out

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
SELECT COUNT(*)
FROM CPM_PND_TRAN_HDR
WHERE ID_EDC_ACCT_NUM = '123141' 
  AND ID_EDC_DUNS = '12312341'
  AND KY_SUPPLIER = 'TESI'
  AND CD_SERVICE = 'X'
  AND DT_PERIOD_START = sysdate 
  AND CD_TRAN_STATUS >= '25' 
  AND CD_TRAN_STATUS <= '68' 
  AND CD_TRAN_TYPE_867 IN ('867','F67','H67','B67') 
  AND CD_PURPOSE IN (SELECT KY_CPM_CD_PURPOSE
                       FROM CPM_CD_PURPOSE
                        WHERE CD_MAJOR_TYPE = 'x' )

/

@utlxpls.sql

spool off