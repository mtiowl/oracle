BEGIN
   dbms_stats.gather_table_stats (ownname => 'PPLSCIS', tabname => 'EDI_TRANSACTION', method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO', estimate_percent => 10);
END;
/

dbms_stats.gather_table_stats (ownname => 'cl2pra', tabname => 'BUS_DIR_NO_INSTMT', method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO', estimate_percent => 10);

dbms_stats.gather_table_stats(ownname => 'PO_AMI',  tabname => 'po_ami_temp', method_opt => 'FOR ALL COLUMNS SIZE AUTO', degree => 2, no_invalidate => false);

dbms_stats.gather_table_stats(ownname => 'cl2pra',  tabname => 'PRICE_USAGE', method_opt => 'FOR ALL COLUMNS SIZE AUTO', degree => 2, no_invalidate => false);


dbms_stats.gather_schema_stats (ownname => 'cl2pra', method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO', degree => 2, no_invalidate => false);