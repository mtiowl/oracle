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
SELECT D.BUDGET_TYPE, D.BUCKET, D.KEY, :B6 , :B5 , D.DATA_TYPE, D.DATA, :B4 
  FROM CMX.BUDGET_KEY_STATUS_DATA D 
  INNER JOIN (SELECT BUDGET_TYPE, BUCKET, KEY, DATA_TYPE, MAX(EFF_DATE) EFF_DATE 
                FROM CMX.BUDGET_KEY_STATUS_DATA 
                GROUP BY BUDGET_TYPE, BUCKET, KEY, DATA_TYPE) DATES 
          ON D.BUDGET_TYPE = DATES.BUDGET_TYPE 
             AND CMX.NULLCOMPARE.EQUAL(D.BUCKET, DATES.BUCKET) = 1 
             AND D.KEY = DATES.KEY 
             AND D.DATA_TYPE = DATES.DATA_TYPE 
             AND D.EFF_DATE = DATES.EFF_DATE 
  WHERE D.BUDGET_TYPE = TRIM(:B3 ) 
    AND (D.BUCKET IS NULL OR D.BUCKET = :B2 ) 
    AND (D.KEY = :B1 OR D.KEY LIKE :B1 || CHR(30) || '%') 
    AND D.STATUS IN (SELECT CODE 
                       FROM CMX.STATUS 
                       WHERE CODE = TRIM(:B7 ) 
                          OR (STAGE >= (SELECT STAGE FROM CMX.STATUS WHERE CODE = TRIM(:B7 )) AND STAGE < (SELECT STAGE FROM CMX.STATUS WHERE CODE = :B5 ))
                    )
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