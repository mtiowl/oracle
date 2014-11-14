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
  FOR SELECT  
        b.KY_PND_SEQ_TRANS, b.KY_ENROLL, b.ID_BA_ESCO, b.DT_PERIOD_START, b.DT_PERIOD_END, 
        b.CD_PURPOSE, b.CD_TRAN_STATUS, b.CD_BILL_TYPE, b.CD_BILL_CALC_METHOD, 
        b.DT_BILLED_BY_CSS
    FROM CUSTPRO.CPM_PND_TRAN_HDR b
        ,PVIEW.CSS_ER_XREF_CUST_INFO a
        ,CPM_PND_EDC_EGS_CHARGES charges
    WHERE b.KY_SUPPLIER = 'TESI' 
        AND b.ID_EDC_DUNS IN('007915606','007916836','007914468','008967614','007909427AC',
                                                   '006971618NJ','006973358','617976758','006973812','006971618MD',
                                                   '043381565EDC','156171464','006920284','006929509','','006920284DC',
                                                   '006971618DE','007911050EDC','007912736','007900293','006998371',
                                                   '007904626','099427866')
        AND (b.DT_PERIOD_START between '01-FEB-2012' and '29-FEB-2012' 
                OR b.DT_PERIOD_END between '01-FEB-2012' and '29-FEB-2012'  
                OR b.DT_PERIOD_START <= '01-FEB-2012' and b.DT_PERIOD_END >= '29-FEB-2012')  
        AND b.CD_TRAN_STATUS = '75' 
        AND b.CD_PURPOSE = '00'
        --AND b.KY_ENROLL IN (123.321)
        AND b.KY_ENROLL = a.KY_OLD_ACCTNO
        --
        AND a.KY_SUPPLIER_ID = 'TESI' 
        AND a.SERV_STATE IN('DC','DE','IL','MD','NJ','OH','PA')
        --
        AND charges.CD_EDI_CODE = 'UCAP2'
        AND charges.ky_pnd_seq_trans = b.ky_pnd_seq_trans
/

@utlxpls.sql