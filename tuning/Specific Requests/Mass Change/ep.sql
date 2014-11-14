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
SELECT *
FROM V_MASS_CHANGE_FILE_LIST
WHERE
(
"ApprovalStatusCode" IS NULL
OR "ApprovalStatusCode" = 'A'
)
AND "ImportedFlag" = 'Y'
AND "FileID" IN
(
SELECT KY_FILE_ID
FROM GOODWRENCH_IMPORT
WHERE
(
FL_PROCESS IS NULL
OR FL_PROCESS = 'N'
)
AND KY_TRANSACTION_TYPE NOT IN
(
SELECT KY_CODE FROM CODE WHERE KY_TABLE = 'DATA_REPAIR'
)
)
ORDER BY "FileID"
/

@utlxpls.sql

spool off