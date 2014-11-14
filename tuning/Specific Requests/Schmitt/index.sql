DROP INDEX mti_test;

create index mti_test on bill_email_history_hdr (fl_processed, ky_bill);

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'BILL_EMAIL_HISTORY_HDR');
END;
/
