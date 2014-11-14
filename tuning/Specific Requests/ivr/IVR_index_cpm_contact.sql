-- CUSTPRO
CREATE INDEX cpm_contact_area_code_phone ON cpm_contact (tx_day_phone_area_code, tx_day_phone_number)
/

BEGIN
    dbms_stats.gather_table_stats('CUSTPRO', 'CPM_CONTACT');
END;
/