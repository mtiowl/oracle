DROP INDEX mti_test_index;

create index mti_test_index on CURVE_DATA_SQLLOADER (curve_code, file_id);

BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'CURVE_DATA_SQLLOADER');
END;
/
