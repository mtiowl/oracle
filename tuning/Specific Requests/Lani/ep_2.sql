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
SELECT a.KY_PA_SEQ ||'|'||
 a.KY_PROFHDR_SEQ  ||'|'||
 a.KY_PROFDTL_SEQ  ||'|'||
 a.QY_ELEM_VALUE   ||'|'||
 a.TX_ELEM_VALUE   ||'|'||
 c.TX_DESCRIPTION  ||'|'||
 b.KY_ENROLL       ||'|'||
 b.KY_SUPPLIER 
 FROM CPM_BILL_DETERMINANT  a
 , CPM_PRODUCT_ACCOUNT  b
 , CPM_PRICE_PROFILE_DTL  c
WHERE a.KY_PA_SEQ = b.KY_PA_SEQ 
  AND a.KY_PROFHDR_SEQ = c.KY_PROFHDR_SEQ 
 AND    a.KY_PROFDTL_SEQ = c.KY_PROFDTL_SEQ 
 AND a.ky_pa_seq IN (SELECT A.KY_PA_SEQ	
                     FROM CPM_PRODUCT_ACCOUNT A
                        , CPM_PRICE_PROFILE_HDR B 
                     WHERE  A.KY_PROFHDR_SEQ = B.KY_PROFHDR_SEQ 
                     AND  A.KY_SUPPLIER = '&&1'
                     AND A.ts_updated > to_date('&&2','mm/dd/yyyy hh:mi:ss AM'))
/

@utlxpls.sql

spool off