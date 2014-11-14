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
SELECT   mcf.ky_file, mcf.tx_file, mcf.cd_approval_status,
         DECODE (cd_approval_status, 'A', 'Approved', NULL, 'Pending', NULL),
         mcf.tx_approve_reject_user, mcf.tx_user, mcf.ky_transaction_type,
         c.tx_decode, mcf.dt_imported, mcf.fl_imported, mcf.tx_comment,
         COUNT (gwi.ky_transaction_id) tcount,
         COUNT (CASE
                   WHEN fl_process = 'Y'
                      THEN ky_transaction_id
                   ELSE NULL
                END) ycount,
         COUNT (CASE
                   WHEN fl_process = 'N'
                      THEN ky_transaction_id
                   ELSE NULL
                END) ncount,
         COUNT (CASE
                   WHEN fl_process = 'R'
                      THEN ky_transaction_id
                   ELSE NULL
                END) rcount
    FROM gw_mass_change_file mcf,
         code c,
         (SELECT DISTINCT ky_transaction_id, ky_file_id, fl_process
                     FROM goodwrench_import) gwi
   WHERE mcf.ky_transaction_type = c.ky_code
     AND gwi.ky_file_id = mcf.ky_file
     AND c.ky_table = 'MASS_CHANGE_TRANS'
GROUP BY mcf.ky_file,
         mcf.tx_file,
         mcf.cd_approval_status,
         mcf.tx_approve_reject_user,
         mcf.tx_user,
         mcf.ky_transaction_type,
         c.tx_decode,
         mcf.dt_imported,
         mcf.fl_imported,
         mcf.tx_comment
/

@utlxpls.sql

spool off