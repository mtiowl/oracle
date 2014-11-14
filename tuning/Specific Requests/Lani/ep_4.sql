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
SELECT   a.KY_PA_SEQ ||'|'||
 a.KY_PROFHDR_SEQ  ||'|'||
 a.KY_PROFDTL_SEQ  ||'|'||
 a.QY_ELEM_VALUE   ||'|'||
 a.TX_ELEM_VALUE   ||'|'||
 c.TX_DESCRIPTION  ||'|'||
 cpa.KY_ENROLL       ||'|'||
 cpb.KY_SUPPLIER 
 FROM CPM_PRODUCT_ACCOUNT cpa
,CPM_BILL_DETERMINANT  a 
, CPM_PRICE_PROFILE_HDR cpb 
, CPM_PRICE_PROFILE_DTL  c
WHERE  cpa.KY_SUPPLIER = 'TESI'
AND cpa.ts_updated > to_date('01/01/1965','mm/dd/yyyy hh:mi:ss AM')
AND a.KY_PA_SEQ = cpa.KY_PA_SEQ
AND cpa.ky_profhdr_seq = c.ky_profhdr_seq
AND cpb.KY_PROFHDR_SEQ = cpa.KY_PROFHDR_SEQ
AND a.KY_PROFDTL_SEQ = c.KY_PROFDTL_SEQ
AND a.KY_PROFHDR_SEQ = c.KY_PROFHDR_SEQ 
/

@utlxpls.sql

spool off