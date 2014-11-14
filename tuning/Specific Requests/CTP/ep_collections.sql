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
DELETE FROM PPLSCIS.CIS_COLLECTIONS_QUEUE 
   WHERE KY_ENROLL IN (SELECT A.KY_ENROLL 
                         FROM PPLSCIS.CIS_COLLECTIONS_QUEUE A 
                              JOIN ENROLL E ON A.KY_ENROLL = E.KY_ENROLL 
                         WHERE E.KY_UTILITY_PROGRAM ='NOPE')
/

@utlxpls.sql