DROP TABLE c14_pjm_bills
/

CREATE TABLE c14_pjm_bills
pctfree 0 nologging tablespace custpro_data
AS SELECT a.CSS_NAME "CustomerName", a.ID_BA_ESCO "UtilityAcct", a.KY_BA "BillAcct", 
       a.KY_OLD_ACCTNO "ERNumber", a.CSS_STATUS "AcctStatus", 
       a.CSS_BILL_OPTION "BillOpt", pa.KY_PROFHDR_SEQ "HdrSeq", 
       pa.KY_PA_SEQ "PASeq", pa.DT_EFF_FROM "ProdFrom", pa.DT_EFF_TO "ProdTo",
       bill_det.TX_ELEM_VALUE "Index", attrib.QY_VALUE "CapRate", 
       b.KY_PND_SEQ_TRANS "BillTrans", b.DT_PERIOD_START "BillStart", 
       b.DT_PERIOD_END "BillEnd", b.CD_PURPOSE "BillPurpose", 
       b.DT_BILLED_BY_CSS "BillDate", b.CD_TRAN_STATUS "BillStatus", 
       b.CD_BILL_TYPE "BillType", b.CD_BILL_CALC_METHOD "BillMethod", 
       charges.CD_EDI_CODE "EDICode", 
       charges.QY_PRNT_PRTY "PrintOrder", charges.TX_TARIFF_DESC "ChargeDesc", 
       charges.AT_CHG "ChargeAmt"
       ,'BILL' record_type
    FROM CUSTPRO.CPM_PND_TRAN_HDR b
        ,PVIEW.CSS_ER_XREF_CUST_INFO a
        ,CPM_PND_EDC_EGS_CHARGES charges
        ,CPM_PRODUCT_ACCOUNT pa
        ,CPM_BILL_DETERMINANT bill_det
        ,MKT_ATTRIBUTE_ALIAS mkt_alias
        ,MKT_ATTRIBUTE_VALUE_RANGE attrib
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
        --
        AND b.DT_PERIOD_START between pa.DT_EFF_FROM and pa.DT_EFF_TO
        AND pa.KY_ENROLL = b.KY_ENROLL
        AND pa.KY_PROFHDR_SEQ = 1000055
        --
        AND pa.KY_PA_SEQ = bill_det.KY_PA_SEQ
        AND bill_det.KY_PROFDTL_SEQ = 3
        --
        AND bill_det.TX_ELEM_VALUE = mkt_alias.CD_NAME
        AND mkt_alias.KY_SUPPLIER = b.ky_supplier
        --
        AND mkt_alias.KY_MKT_ATTRIBUTE_HDR = attrib.KY_MKT_ATTRIBUTE_HDR
        AND attrib.DT_EFF_TO = '31-DEC-9999'
        AND attrib.DT_MARKET_DATE_FROM = '01-FEB-2012'
        AND attrib.DT_MARKET_DATE_TO = '29-FEB-2012'
UNION
  SELECT a.CSS_NAME "CustomerName", a.ID_BA_ESCO "UtilityAcct", a.KY_BA "BillAcct", 
         a.KY_OLD_ACCTNO "ERNumber", a.CSS_STATUS "AcctStatus", 
         a.CSS_BILL_OPTION "BillOpt", null, 
         null, null, null,
         null, null, 
         b.KY_PND_SEQ_TRANS "BillTrans", b.DT_PERIOD_START "BillStart", 
         b.DT_PERIOD_END "BillEnd", b.CD_PURPOSE "BillPurpose", 
         b.DT_BILLED_BY_CSS "BillDate", b.CD_TRAN_STATUS "BillStatus", 
         b.CD_BILL_TYPE "BillType", b.CD_BILL_CALC_METHOD "BillMethod", 
         null, 
         null, null, 
         null
        ,'CANCEL' record_type
    FROM CUSTPRO.CPM_PND_TRAN_HDR b
        ,PVIEW.CSS_ER_XREF_CUST_INFO a
    WHERE b.KY_ENROLL = a.ky_old_acctno
      AND b.KY_SUPPLIER = 'TESI' 
      AND b.ID_EDC_DUNS IN('007915606','007916836','007914468','008967614','007909427AC',
                                                   '006971618NJ','006973358','617976758','006973812','006971618MD',
                                                   '043381565EDC','156171464','006920284','006929509','','006920284DC',
                                                   '006971618DE','007911050EDC','007912736','007900293','006998371',
                                                   '007904626','099427866')
      --AND (   b.DT_PERIOD_START between '01-FEB-2012' and '29-FEB-2012' 
      --     OR b.DT_PERIOD_START <= '01-FEB-2012' and b.DT_PERIOD_END >= '29-FEB-2012' )  
      AND (b.DT_PERIOD_START between '01-FEB-2012' and '29-FEB-2012' 
                OR b.DT_PERIOD_END between '01-FEB-2012' and '29-FEB-2012'  
                OR b.DT_PERIOD_START <= '01-FEB-2012' and b.DT_PERIOD_END >= '29-FEB-2012')
      AND b.CD_TRAN_STATUS = '75' 
      AND b.CD_PURPOSE = '01'
      AND a.KY_SUPPLIER_ID = 'TESI' 
      AND a.SERV_STATE IN('DC','DE','IL','MD','NJ','OH','PA')
/