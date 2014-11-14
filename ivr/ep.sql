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
SELECT a.ky_enroll, a.tx_service_zip, a.tx_utility_account, e.ky_enroll_status
  FROM PVIEW.ACCOUNT a, PVIEW.ENROLL e, CUSTPRO.CPM_CONTACT c
  WHERE a.ky_enroll = e.ky_enroll
    AND a.ky_enroll = c.ky_enroll
    AND a.ky_supplier = :p_supplier_id
    AND a.ky_account_type = :p_service_type
    AND c.tx_day_phone_area_code = SUBSTR(:p_phone_number,1,3)
    AND c.tx_day_phone_number = SUBSTR(:p_phone_number,5,8)
    AND e.ky_enroll_status IN ('TBR','RREQ','RFLD','TBC','PTBC','CUST','PRMT','PSPT','PFNL')
/

@utlxpls.sql