-- CPES @ ERS%
CREATE INDEX cas_prospect_status_supplier ON cas_prospect (status, supplier_id)
/

BEGIN
    dbms_stats.gather_table_stats('CPES', 'CAS_PROSPECT');
END;
/