SPOOL ep.out

REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

COMMIT
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT D.KY_BILL||'|'||D.KY_ENROLL
  FROM CPM_PND_TRAN_HDR A
      ,CPM_TAX_LOG_HDR B
      ,CPM_TAX_LOG_DTL C
      ,BILL_HDR bhdr D
  WHERE A.ky_pnd_seq_trans = B.ky_pnd_seq_trans 
    AND B.ky_log_seq = C.ky_log_seq 
    AND A.ky_enroll = bhdr.ky_enroll 
    AND A.dt_billed_by_css = bhdr.dt_bill 
    AND A.cd_tran_status = '75' 
    AND A.cd_purpose IN (SELECT ky_cpm_cd_purpose FROM cpm_cd_purpose  WHERE cd_major_type = 'BILL') 
    AND bhdr.ky_supplier = 'TESI'
    AND (   A.ts_last_updated > to_date('01/01/2011 00:00:00 AM','mm/dd/yyyy hh:mi:ss AM')
         OR bhdr.dt_modify    > to_date('01/01/2011 23:59:59 PM','mm/dd/yyyy hh:mi:ss AM')
        )
/

@utlxpls.sql

spool off