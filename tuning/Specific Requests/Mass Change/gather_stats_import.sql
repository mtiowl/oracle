BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'GOODWRENCH_IMPORT');
END;
/