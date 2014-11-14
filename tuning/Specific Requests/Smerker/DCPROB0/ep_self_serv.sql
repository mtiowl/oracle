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
  SELECT DISTINCT MSTR_PH.KY_BA, MSTR_PH.DT_BILLED_BY_CSS, MSTR_PH.KY_SUPPLIER
    FROM CPM_SUMMBILL_PND_LNK PND_LNK, CPM_PND_TRAN_HDR MBR_PH, CPM_PND_TRAN_HDR MSTR_PH, CPM_CD_PURPOSE PURP
    WHERE MBR_PH.KY_SUPPLIER = 'xxx'
      AND MBR_PH.KY_ENROLL = 123
      AND MBR_PH.DT_BILLED_BY_CSS = sysdate
      AND PND_LNK.KY_PND_SEQ_MEMBER = MBR_PH.KY_PND_SEQ_TRANS
      AND MSTR_PH.KY_PND_SEQ_TRANS = PND_LNK.KY_PND_SEQ_MASTER
      AND MSTR_PH.CD_TRAN_STATUS = '75'
      AND PURP.KY_CPM_CD_PURPOSE = MBR_PH.CD_PURPOSE
      AND PURP.CD_MAJOR_TYPE = 'BILL'
   UNION ALL
   SELECT DISTINCT MSTR_PH.KY_BA, MSTR_PH.DT_BILLED_BY_CSS, MSTR_PH.KY_SUPPLIER
     FROM CPM_PND_TRAN_HDR MSTR_PH, CPM_CD_PURPOSE PURP
     WHERE MSTR_PH.KY_SUPPLIER = 'TESi'
       AND MSTR_PH.KY_ENROLL = 123
       AND MSTR_PH.DT_BILLED_BY_CSS = SYSDATE
       AND PURP.KY_CPM_CD_PURPOSE = MSTR_PH.CD_PURPOSE
       AND PURP.CD_MAJOR_TYPE = 'BILL'
/

@utlxpls.sql

spool off