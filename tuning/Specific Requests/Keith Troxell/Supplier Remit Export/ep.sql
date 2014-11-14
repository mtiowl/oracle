REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;

CREATE INDEX mti_test ON supplier_remit (cd_tran_id, dt_prcs);
DROP INDEX mti_test;

DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
select * 
 from supplier_remit
 where (   (dt_prcs > to_char(trunc(sysdate)-7, 'YYYY-MM-DD') and cd_tran_id <> '9999') 
         or cd_tran_id = '0200'  
         or cd_tran_id = '0400'  
       )
--   and sr_seq_no > 1
--   and sr_seq_no < 200000
/

@utlxpls.sql