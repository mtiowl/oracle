BEGIN
    dbms_stats.gather_table_stats('CL2PRP', 'SUPPLIER_REMIT');
END;
/