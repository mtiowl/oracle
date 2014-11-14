REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE


alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
    SELECT a.ky_supplier_id, a.ky_edc_acctno, a.cd_edc_nm, b.state, a.cd_service,
           a.nm_cust_bus, b.duns_num, a.cd_duns_grp, a.ad_serv_zip, a.ky_er_ref_id,
           CD_RGSTRTN_STATUS, CD_ENROLL_STATUS
    FROM ERADMIN.CUSTOMER a, ERADMIN.EDC_NAME b
    WHERE CD_RGSTRTN_STATUS = 'PPRE'
    AND a.cd_edc_nm = b.code
    AND a.cd_service = b.cd_service
/

@utlxpls.sql