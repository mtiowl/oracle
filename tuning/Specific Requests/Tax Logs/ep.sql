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
SELECT STATUS 
FROM  CONTROL_867@css_custpro_batch_user
             WHERE KY_BA = 'x'
               AND TX_XREF_NO = 'x'
               --AND CD_TRANS = 'x'
               AND CD_EDI_PURPOSE = 'x'
               AND SENT_TO_CSS = 'Y'
/

@utlxpls.sql