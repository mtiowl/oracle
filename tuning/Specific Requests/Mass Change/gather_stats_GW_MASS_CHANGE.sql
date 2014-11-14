BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'GW_MASS_CHANGE_FILE');
END;
/