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
SELECT *
  from EVENTS
  WHERE SUBSTR(TX_EVENT_DATA,1,INSTR(TX_EVENT_DATA,'|',1)-1) = 'x'
    AND CD_PUBLISHER = 'CTP' AND CD_EVENT = 'IBIMR'
/

@utlxpls.sql