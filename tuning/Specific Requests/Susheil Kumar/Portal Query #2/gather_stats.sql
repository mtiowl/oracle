BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'ACCOUNT');
    dbms_stats.gather_table_stats('PVIEW', 'ENROLL');
END;
/