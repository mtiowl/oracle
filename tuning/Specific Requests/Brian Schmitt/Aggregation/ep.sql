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
SELECT pv.ky_enroll
  from pview.account     pv
      ,cpm_agg_member    am
      ,cpm_agg_header    ah
      ,cpm_cd_agg_type   at
      ,cpm_cd_member_type mt
  where pv.ky_enroll = am.ky_enroll
    and am.ky_cpm_agg_header = ah.ky_cpm_agg_header
    and at.cd_agg_type = ah.cd_agg_type
    and at.ky_supplier = ah.ky_supplier
    and mt.cd_member_type = am.cd_member_type 
    and mt.ky_supplier = ah.ky_supplier
    and ah.ky_supplier = 'TESI'
    AND at.fl_active != 'N'
/

@utlxpls.sql