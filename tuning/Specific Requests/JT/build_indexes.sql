-- ****************************************************************************
--          PVIEW
-- ****************************************************************************
create index mti_test_1 on CSS_ER_XREF_CUST_INFO (KY_SUPPLIER_ID,SERV_STATE)
/

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'CSS_ER_XREF_CUST_INFO');
END;
/



-- ****************************************************************************
--          CUSTPRO
-- ****************************************************************************
create index mti_test_2 on cpm_pnd_tran_hdr (KY_SUPPLIER
                                            ,CD_TRAN_STATUS
                                            ,CD_PURPOSE
                                            ,ID_EDC_DUNS
                                            ,KY_ENROLL)
/

BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'CPM_PND_TRAN_HDR');
END;
/



create index mti_test_3 on CPM_PRODUCT_ACCOUNT (KY_PROFHDR_SEQ
                                               ,KY_ENROLL)
/

BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'CPM_PRODUCT_ACCOUNT');
END;
/


create index mti_test_4 on MKT_ATTRIBUTE_VALUE_RANGE (KY_MKT_ATTRIBUTE_HDR
                                                    ,DT_EFF_TO
                                                    ,DT_MARKET_DATE_FROM
                                                    ,DT_MARKET_DATE_TO)
/

BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'MKT_ATTRIBUTE_VALUE_RANGE');
END;
/