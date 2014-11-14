set serveroutput on size 1000000

DECLARE
  P_KY_SUPPLIER VARCHAR2(200);
  P_DT_BILLED_BY_CSS DATE;
  P_SETTLE_TYPE VARCHAR2(200);
  P_ERROR_REC CUSTPRO.PCPM.ERROR_REC;
BEGIN
  pcpm_settlement_support_mti.m_debugging := true;
  P_KY_SUPPLIER := 'TESI';
  P_DT_BILLED_BY_CSS := '03-JUN-11';
  P_SETTLE_TYPE := 'STLBAND';
  -- Modify the code to initialize the variable
  -- P_ERROR_REC := NULL;

  PCPM_SETTLEMENT_SUPPORT_MTI.PROCESSDAILYSUPPLIER(
    P_KY_SUPPLIER => P_KY_SUPPLIER,
    P_DT_BILLED_BY_CSS => P_DT_BILLED_BY_CSS,
    P_SETTLE_TYPE => P_SETTLE_TYPE,
    P_ERROR_REC => P_ERROR_REC
  );
  
--DBMS_OUTPUT.PUT_LINE('P_ERROR_REC = ' || P_ERROR_REC);
 
  --:P_ERROR_REC := P_ERROR_REC;
END;

/