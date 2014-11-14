create index cpm_pnd_tran_hdr_ix12 on cpm_Pnd_tran_hdr (DT_BILLED_BY_CSS, CD_TRAN_STATUS, DT_PERIOD_START) TABLESPACE CUSTPRO_INDX
/

create index cpm_pnd_tran_hdr_ix12a on CPM_PND_TRAN_HDR (DT_BILLED_BY_CSS,CD_TRAN_STATUS,DT_PERIOD_START,KY_PND_SEQ_TRANS)
    TABLESPACE custpro_indx
    COMPRESS 3
/
    
    
exec dbms_stats.gather_table_stats('CUSTPRO', 'CPM_PND_TRAN_HDR')
