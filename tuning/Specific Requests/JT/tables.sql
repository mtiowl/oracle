CREATE TABLE c14_xref
pctfree 0 nologging tablespace custpro_data
AS SELECT a.ID_BA_ESCO, a.KY_BA, a.KY_OLD_ACCTNO, a.KY_SUPPLIER_ID, a.SERV_STATE, a.CSS_NAME, 
          a.CSS_STATUS, a.CSS_BILL_OPTION
     FROM PVIEW.CSS_ER_XREF_CUST_INFO a
     WHERE a.KY_SUPPLIER_ID = 'TESI' 
       AND a.SERV_STATE IN('DC','DE','IL','MD','NJ','OH','PA')
/

CREATE TABLE c14_pjm_bills
pctfree 0 nologging tablespace custpro_data
AS SELECT  b.KY_PND_SEQ_TRANS, b.KY_ENROLL, b.ID_BA_ESCO, b.DT_PERIOD_START, b.DT_PERIOD_END, 
           b.CD_PURPOSE, b.CD_TRAN_STATUS, b.CD_BILL_TYPE, b.CD_BILL_CALC_METHOD, 
           b.DT_BILLED_BY_CSS
           'BILL' as record_type
    FROM CUSTPRO.CPM_PND_TRAN_HDR b
    WHERE b.KY_SUPPLIER = 'TESI' 
      AND b.ID_EDC_DUNS IN('007915606','007916836','007914468','008967614','007909427AC',
                                                   '006971618NJ','006973358','617976758','006973812','006971618MD',
                                                   '043381565EDC','156171464','006920284','006929509','','006920284DC',
                                                   '006971618DE','007911050EDC','007912736','007900293','006998371',
                                                   '007904626','099427866')
      AND (   b.DT_PERIOD_START between '01-FEB-2012' and '29-FEB-2012' 
           OR b.DT_PERIOD_END between '01-FEB-2012' and '29-FEB-2012'  
           OR b.DT_PERIOD_START <= '01-FEB-2012' and b.DT_PERIOD_END >= '29-FEB-2012')  
      AND b.CD_TRAN_STATUS = '75' 
      AND b.CD_PURPOSE = '00'
      AND b.KY_ENROLL IN (SELECT KY_OLD_ACCTNO FROM c14_xref)
/

CREATE TABLE c14_cancels
pctfree 0 nologging tablespace custpro_data
AS SELECT b.KY_PND_SEQ_TRANS, b.KY_ENROLL, b.ID_BA_ESCO, b.DT_PERIOD_START, b.DT_PERIOD_END, 
          b.CD_PURPOSE, b.CD_TRAN_STATUS, b.CD_BILL_TYPE, b.CD_BILL_CALC_METHOD, 
          b.DT_BILLED_BY_CSS
          'CANCEL' as record_type
    FROM CUSTPRO.CPM_PND_TRAN_HDR b
    WHERE b.KY_ENROLL IN (SELECT KY_ENROLL FROM c14_pjm_bills)
      AND b.KY_SUPPLIER = 'TESI' 
      AND b.ID_EDC_DUNS IN('007915606','007916836','007914468','008967614','007909427AC',
                                                   '006971618NJ','006973358','617976758','006973812','006971618MD',
                                                   '043381565EDC','156171464','006920284','006929509','','006920284DC',
                                                   '006971618DE','007911050EDC','007912736','007900293','006998371',
                                                   '007904626','099427866')
      AND (   b.DT_PERIOD_START between '01-FEB-2012' and '29-FEB-2012' 
           OR b.DT_PERIOD_START <= '01-FEB-2012' and b.DT_PERIOD_END >= '29-FEB-2012' )  
      AND b.CD_TRAN_STATUS = '75' 
      AND b.CD_PURPOSE = '01'
/

CREATE TABLE ucap_trans
pctfree 0 nologging tablespace custpro_data
AS SELECT c.KY_PND_SEQ_TRANS, c.CD_EDI_CODE, c.QY_PRNT_PRTY, c.TX_TARIFF_DESC, c.AT_CHG, 
          c.TX_UOM, c.AT_QTY, c.AT_RATE
    FROM CUSTPRO.CPM_PND_EDC_EGS_CHARGES c
    WHERE c.CD_EDI_CODE = 'UCAP2'
/