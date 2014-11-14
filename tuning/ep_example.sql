REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE
set linesize 300
set pagesize 500


DELETE plan_table where statement_id = '&statement_tag'
/

EXPLAIN PLAN
  SET STATEMENT_ID = '&statement_tag'
  INTO plan_table
  FOR
SELECT COUNT(*) 
  FROM CPM_PND_TRAN_HDR 
  WHERE ID_EDC_ACCT_NUM = :B3 
    AND ID_EDC_DUNS = :B2 
    AND CD_TRAN_STATUS IN ('28','65') 
    AND CD_PURPOSE IN ('01','17') 
    AND CD_SERVICE =   :B1 
/


--Format Options:
-- 'TYPICAL'. Other values include 'BASIC', 'ALL', 'SERIAL'. There is also an undocumented 'ADVANCED' 
SET HEADING OFF
SELECT * 
  FROM  TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE', '&statement_tag', 'ALL'));

SET HEADING ON  


set linesize 100
set pagesize 50