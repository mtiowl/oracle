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
SELECT *
  FROM edi_file_header efh
      ,edi_header eh
      ,edi_func_group fg
      ,edi_transaction t
  WHERE eh.id_edi_file_header = efh.id_edi_file_header
    AND fg.id_edi_header = eh.id_edi_header
    AND t.id_edi_func_group = fg.id_edi_func_group
    AND t.CD_TRANS_TYPE  ='810'
    AND efh.CD_BUSINESS_UNIT = 'PPLSolutions'
--    AND trunc(efh.DT_TRANS_DATE) BETWEEN trunc(TO_DATE('20-Aug-2011 00:00', 'DD-MON-YYYY HH24:MI'))
--                                     AND trunc(TO_DATE('21-Aug-2011 00:00', 'DD-MON-YYYY HH24:MI'))
/

@utlxpls.sql