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
SELECT cpa.ky_pa_seq
 FROM CPM_PRODUCT_ACCOUNT cpa
     ,CPM_PRICE_PROFILE_HDR  pph
     ,cpm_price_profile_dtl  ppd
     ,cpm_bill_determinant   bd
WHERE cpa.KY_SUPPLIER = 'TESI'
  AND cpa.ts_updated > to_date('01/01/1965','mm/dd/yyyy hh:mi:ss AM')
  AND pph.ky_profhdr_seq = cpa.ky_profhdr_seq
  AND pph.ky_profhdr_seq = ppd.ky_profhdr_seq
  AND bd.ky_profhdr_seq = ppd.ky_profhdr_seq
  AND bd.ky_profdtl_seq = ppd.ky_profdtl_seq
  AND bd.ky_pa_seq = cpa.ky_pa_seq
/

@utlxpls.sql

spool off