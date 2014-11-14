REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE
set linesize 300
set pagesize 500

--alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR  SELECT COUNT(*) 
         FROM "CPM_PND_TRAN_HDR" "A1" 
         WHERE TRUNC("A1"."DT_BILLED_BY_CSS")=TRUNC(sysdate) 
           AND "A1"."CD_TRAN_STATUS"='75' 
           AND "A1"."CD_BILL_TYPE"='ESP' 
           AND "A1"."CD_BILL_CALC_METHOD"='DUAL'
/

REM @utlxpls.sql

SELECT plan_table_output FROM TABLE(dbms_xplan.display(null, 'MTI', 'ALL') );

set linesize 100
set pagesize 50