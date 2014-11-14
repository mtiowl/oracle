BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'CPM_PND_TRAN_HDR');
END;
/