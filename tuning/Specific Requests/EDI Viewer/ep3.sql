REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
select fh.* 
from edi_file_header fh
    ,edi_header h
    ,edi_func_group fg
    ,edi_transaction t
--where fh.cd_business_unit = 'PPLSolutions'
WHERE fh.id_edi_file_header = h.id_edi_file_header
  and h.id_edi_header = fg.id_edi_header
  and t.id_edi_func_group = fg.id_edi_func_group
/
@utlxpls.sql