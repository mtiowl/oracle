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
SELECT ph.ky_pnd_seq_trans, ph.dt_period_start, ph.dt_period_end
          ,ph.dt_billed_by_css
          ,purp.cd_major_type
      FROM cpm_pnd_tran_hdr ph
          ,cpm_cd_purpose purp
      WHERE ph.ky_enroll = 1613849
        AND (   ph.dt_period_start BETWEEN '01-SEP-2011' AND '30-SEP-2011'
             OR ph.dt_period_end BETWEEN '01-SEP-2011' AND '30-SEP-2011'
             OR (ph.dt_period_start < '01-SEP-2011' AND ph.dt_period_end > '30-SEP-2011')
            )
        AND ph.cd_tran_status = '75'
        AND purp.ky_cpm_cd_purpose = ph.cd_purpose
      ORDER BY ph.dt_billed_by_css, purp.cd_major_type DESC
/

@utlxpls.sql

spool off