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
SELECT bill.KY_BILL
FROM CPM_PND_TRAN_HDR PTH
   , CPM_TAX_LOG_HDR tlh
   , CPM_TAX_LOG_DTL tld
   , BILL_HDR bill
WHERE PTH.ky_pnd_seq_trans = tlh.ky_pnd_seq_trans
  AND tlh.ky_log_seq = tld.ky_log_seq
  AND PTH.ky_enroll = bill.ky_enroll
  AND PTH.dt_billed_by_css = bill.dt_bill
  AND PTH.cd_tran_status = '75'
  AND PTH.cd_purpose IN (SELECT ky_cpm_cd_purpose FROM cpm_cd_purpose  WHERE cd_major_type = 'BILL')
  AND PTH.ky_enroll = tlh.ky_enroll
  AND PTH.ky_supplier = tlh.ky_supplier
  AND tlh.ky_enroll = bill.ky_enroll
  AND tlh.ky_supplier = bill.ky_supplier
  AND PTH.ky_supplier = 'TESI'
  AND tlh.ky_supplier = 'TESI'
  AND bill.ky_supplier = 'TESI'
--AND nvl(PTH.dt_billed_by_css,sysdate) > to_date('01/01/1965 12:00:00 AM','mm/dd/yyyy hh:mi:ss AM')
--AND nvl(tlh.dt_billed,sysdate) > to_date('01/01/1965 12:00:00 AM','mm/dd/yyyy hh:mi:ss AM')
  AND (PTH.ts_last_updated > sysdate-1  OR bill.dt_modify > sysdate-1)
/

@utlxpls.sql

spool off