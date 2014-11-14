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
SELECT distinct KY_REG_REF_NO, CD_TRANS_TYPE, CD_ORIG_TRANS_TYPE, KY_EDC_ACCTNO, EDI_DATA, KY_TRANS_GRP_ID, CD_SERVICE 
  FROM EDI_REG_INBOUND_814 
  WHERE RECORD_TYPE = :B2 
    --AND FL_PROCESSED <> 'Y'
    AND FL_PROCESSED is null
    AND CD_BUS_APP = :B1 
   ORDER BY KY_REG_REF_NO, KY_TRANS_GRP_ID, SUBSTR(EDI_DATA, 640, 1) DESC
/

@utlxpls.sql