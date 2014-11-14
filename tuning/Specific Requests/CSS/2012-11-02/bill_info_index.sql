-- CPES @ ERS%
CREATE INDEX bill_info_hdr_dt_due ON bill_info_hdr (DT_DUE)
/

BEGIN
    dbms_stats.gather_table_stats('CL2PRP', 'BILL_INFO_HDR');
END;
/