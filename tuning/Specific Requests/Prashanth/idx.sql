
-- PPLSCIS schema
CREATE INDEX cl_hdr_mti_test ON cis_cl_header (trunc(ts_modified), cd_follow_up_status, ky_call_log_id, ky_enroll, tx_billing_number, ts_added)
/

CREATE INDEX cl_hdr_mti_test ON cis_cl_header (ky_call_log_id, cd_follow_up_status, trunc(ts_modified), ky_enroll, tx_billing_number, ts_added,id_user_guid)
/

CREATE INDEX cl_hdr_mti_test ON cis_cl_header (cd_follow_up_status, trunc(ts_modified), ky_call_log_id, ky_enroll, tx_billing_number)
/

CREATE INDEX cl_hdr_mti_test ON cis_cl_header (cd_follow_up_status, trunc(ts_modified), ky_call_log_id, ky_enroll, tx_billing_number, id_user_guid)
/

CREATE INDEX cl_hdr_mti_test ON cis_cl_header (cd_follow_up_status, ts_modified, ky_call_log_id, ky_enroll, tx_billing_number)
/


CREATE INDEX cl_hdr_mti_test ON cis_cl_header (cd_follow_up_status, ts_modified, ky_call_log_id, ky_enroll, tx_billing_number, id_user_guid, ts_added)
/




CREATE INDEX cl_call_type_mti_test ON cis_cl_call_types (ky_call_log_id, tx_call_type)
/

BEGIN
    dbms_stats.gather_table_stats('PPLSCIS', 'cis_cl_header');
    dbms_stats.gather_table_stats('PPLSCIS', 'cis_cl_call_types');
    dbms_stats.gather_table_stats('PPLSCIS', 'cis_cl_messages');
END;
/


--PVIEW schema
CREATE INDEX acct_mti_test2 ON account (ky_enroll,ky_supplier,tx_customer_name)
/

BEGIN
    dbms_stats.gather_table_stats('Pview', 'account');
END;
/