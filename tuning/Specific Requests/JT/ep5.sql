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
  FOR SELECT d.KY_PROFHDR_SEQ, d.DT_EFF_FROM, d.DT_EFF_TO, d.KY_PA_SEQ, d.KY_ENROLL, e.TX_ELEM_VALUE,
             f.KY_MKT_ATTRIBUTE_HDR, f.DT_MARKET_DATE_FROM, f.DT_MARKET_DATE_TO, f.QY_VALUE
    FROM CUSTPRO.CPM_PRODUCT_ACCOUNT d
        ,CUSTPRO.CPM_BILL_DETERMINANT e
        ,CUSTPRO.MKT_ATTRIBUTE_VALUE_RANGE f
        ,CUSTPRO.MKT_ATTRIBUTE_ALIAS g
    WHERE d.KY_ENROLL IN (123,321)
      AND d.KY_PROFHDR_SEQ = 1000055
      AND d.KY_PA_SEQ = e.KY_PA_SEQ
      AND e.KY_PROFDTL_SEQ = 3
      AND e.TX_ELEM_VALUE = g.CD_NAME
      AND g.KY_SUPPLIER = 'TESI'
      AND g.KY_MKT_ATTRIBUTE_HDR = f.KY_MKT_ATTRIBUTE_HDR
      AND f.DT_EFF_TO = '31-DEC-9999'
      AND f.DT_MARKET_DATE_FROM = '01-FEB-2012'
      AND f.DT_MARKET_DATE_TO = '29-FEB-2012'
/

@utlxpls.sql