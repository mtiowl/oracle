-- ****************************************************************************
--          PVIEW
-- ****************************************************************************
create index mti_test_EDI_REG_INBOUND on EDI_REG_INBOUND_814 (RECORD_TYPE, FL_PROCESSED, CD_BUS_APP )
/

BEGIN
    dbms_stats.gather_table_stats('ERADMIN', 'EDI_REG_INBOUND_814');
END;
/

