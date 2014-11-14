REM set timing on;
SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

--EXPLAIN PLAN
--  SET STATEMENT_ID = 'MTI'
--  INTO plan_table
--  FOR
--SELECT pv.ky_enroll
--  from pview.account     pv
--      ,cpm_agg_member    am
--      ,cpm_agg_header    ah
--      ,cpm_cd_agg_type   at
--      ,cpm_cd_member_type mt
--  where pv.ky_enroll = am.ky_enroll
--    and am.ky_cpm_agg_header = ah.ky_cpm_agg_header
--    and at.cd_agg_type = ah.cd_agg_type
--    and at.ky_supplier = ah.ky_supplier
--    and mt.cd_member_type(+) = am.cd_member_type 
--    and mt.ky_supplier(+) = ah.ky_supplier
--    and ah.ky_supplier = 'TESI'
--    AND at.fl_active != 'N'

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT cam.ky_cpm_agg_member
      ,cam.ky_enroll
      ,acct.tx_customer_name
      ,acct.ky_utility_name
      ,cah.ky_supplier
      ,cat.cd_agg_type
      ,cat.tx_description AS cd_agg_type_desc
      ,cah.tx_agg_value
      ,cam.cd_member_type
      ,cam.ky_cpm_agg_header
      ,cat.fl_contiguous
      ,cam.dt_eff_from
      ,cam.dt_eff_to
      ,cam.tx_source_doc
      ,cam.tx_comment
      ,cam.ts_updated
      ,cam.tx_updated_by
      ,(SELECT tx_description
          FROM cpm_cd_member_type 
          WHERE cd_member_type = cam.cd_member_type
            AND ky_supplier = cah.ky_supplier
       ) cd_member_type_desc
  FROM  cpm_agg_member cam
       ,cpm_agg_header cah
       ,cpm_cd_agg_type cat
       ,pview.account acct
  WHERE cam.ky_cpm_agg_header = cah.ky_cpm_agg_header
    AND (cat.cd_agg_type = cah.cd_agg_type AND cat.ky_supplier = cah.ky_supplier)
    AND acct.ky_enroll = cam.ky_enroll
    AND cah.ky_supplier = 'TESI'
    AND cat.fl_active != 'N'

/

@utlxpls.sql