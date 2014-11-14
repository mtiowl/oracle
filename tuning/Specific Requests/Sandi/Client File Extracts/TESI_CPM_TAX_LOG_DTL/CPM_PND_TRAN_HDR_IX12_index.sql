REM ***************************************************************
REM    Performance improvement for Client File Extracts
REM    Module: PSOL_TESI_CPM_TAX_LOG_DTL.sql
REM
REM    Date: 16-DEC-2011
REM
REM    Used to reduce cost from 46,654 to 2,207
REM    
REM ***************************************************************
create index CPM_PND_TRAN_HDR_IX12 on cpm_pnd_tran_hdr(cd_purpose)
/
