-- PVIEW
DROP INDEX mti_test_indx;
CREATE INDEX mti_test_indx ON email_list (supplier, kyvalue, templatename, addedon);

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'email_list');
END;
/


-- Owned by PPLSCIS
CREATE INDEX mti_test_indx_2 ON cis_collections_queue (ky_supplier
                                                      ,ky_enroll
                                                      ,cd_queue_status
                                                      ,ky_utility_name);
BEGIN
    dbms_stats.gather_table_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE');
    dbms_stats.gather_index_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE_IDX_2');
    dbms_stats.gather_index_stats('PPLSCIS', 'CIS_COLLECTIONS_QUEUE_IDX_3');
    dbms_stats.gather_index_stats('PPLSCIS', 'MTI_TEST_INDX_2');
END;
/
