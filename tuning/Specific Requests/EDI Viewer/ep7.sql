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
SELECT i.rn, t.* 
  FROM (SELECT i.*
          FROM (SELECT i.*, ROWNUM AS rn 
                  FROM (
                        SELECT t.ROWID AS a_rowid
                          FROM edi_file_header fh
                              ,edi_header h 
                              ,edi_func_group fg
                              ,edi_transaction t
                          WHERE h.id_edi_file_header = fh.id_edi_file_header
                            AND h.id_edi_header = fg.id_edi_header
                            AND fg.id_edi_func_group = t.id_edi_func_group
                            AND trunc(fh.DT_TRANS_DATE) >= trunc(to_date('01-AUG-2011', 'DD-MON-YYYY'))
                            AND trunc(fh.DT_TRANS_DATE) <= trunc(to_date('31-AUG-2011', 'DD-MON-YYYY'))
                            AND fh.cd_business_unit = 'PPLSolutions'
                            AND t.CD_TRANS_TYPE = '810'
                       ) i
                 WHERE ROWNUM <= 50
               ) i
         WHERE rn >= 1
       ) i
       ,edi_file_header fh
       ,edi_header h 
       ,edi_func_group fg
       ,edi_transaction t
  WHERE h.id_edi_file_header = fh.id_edi_file_header
    AND h.id_edi_header = fg.id_edi_header
    AND fg.id_edi_func_group = t.id_edi_func_group
    AND i.a_rowid = t.ROWID
 ORDER BY rn
/

@utlxpls.sql