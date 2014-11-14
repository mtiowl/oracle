DROP TABLE goodwrench_transactions
/

CREATE TABLE goodwrench_transactions
as select distinct ky_file_id, ky_transaction_id, fl_process
    from goodwrench_import
/

CREATE INDEX gw_trans_ix ON goodwrench_transactions (ky_file_id)
/

CREATE INDEX gw_trans_ix2 ON goodwrench_transactions (ky_file_id, fl_process)
/

BEGIN
    dbms_stats.gather_table_stats('PVIEW', 'GOODWRENCH_TRANSACTIONS');
END;
/