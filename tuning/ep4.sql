REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE
set linesize 300
set pagesize 500


--alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;

--
--   FOR 11g:
--alter session set optimizer_mode = ALL_ROWS



DELETE plan_table where statement_id = 'MTI';
COMMIT;


EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
select a.paymt_ref_no 
  from VENTYX.tidapmst a
  where a.paymt_ref_no = :a1
    and a.invoice_status = 'CANCELED'
/


--@utlxpls.sql

--Format Options:
-- 'TYPICAL'. Other values include 'BASIC', 'ALL', 'SERIAL'. There is also an undocumented 'ADVANCED' 
SET HEADING OFF
SELECT * 
  FROM  TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE', 'MTI', 'SERIAL'));

SET HEADING ON  

set linesize 100
set pagesize 50