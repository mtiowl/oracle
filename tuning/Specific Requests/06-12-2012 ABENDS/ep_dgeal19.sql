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
SELECT KY_PND_SEQ_TRANS, ID_BA_ESCO, KY_BA,                                                                                                                                                                                                                                             
  KY_SUPPLIER, CD_TRAN_TYPE_867, ID_TRANS_REF_NUM_867, ID_EDC_DUNS,                                                                                                                                                                                                                                         
  DT_PERIOD_START, DT_PERIOD_END, CD_FINAL, DT_DOC_DUE, CD_PURPOSE,                                                                                                                                                                                                                                         
  KY_ENROLL, CD_SERVICE, CD_BILL_TYPE, CD_BILL_CALC_METHOD                                                                                                                                                                                                                                                  
  FROM CPM_PND_TRAN_HDR@PSOL_CSS_BATCH_USER.WORLD WHERE CD_TRAN_STATUS = '70';
/

@utlxpls.sql