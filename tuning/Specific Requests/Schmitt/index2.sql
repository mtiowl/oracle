DROP INDEX mti_test_bill_hdr;

create index mti_test_bill_hdr on bill_hdr (ky_bill, dt_bill_due);

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'BILL_HDR');
END;
/
