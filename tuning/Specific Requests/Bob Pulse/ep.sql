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
SELECT  DBACTVY.KY_BA,
        SUPPACCT.KY_SUPPLIER_ID,
        DBACTVY.DT_DB_STAT,
        DBACTVY.AT_DB,
        DBACTVY.DT_DB,
        DBACTVY.AT_REMN_DB,
        DBACTVY.DT_BILL,
        BLINFHDR.DT_DUE,
        SUPPACCT.NO_DUE_DAYS,
        (TRUNC(SYSDATE) - TO_DATE(BLINFHDR.DT_DUE,'YYYY-MM-DD'))  AS  "NO_DAYS_OVERDUE",
        DECODE(BLINFHDR.DT_DUE, '0001-01-01', '2012-02-09',
                                NULL        , NULL,
                                BLINFHDR.DT_DUE)    AS    Calc_DT_DUE,
        TO_DATE(SUBSTR(DBACTVY.DT_BILL,1,10),'YYYY-MM-DD') + SUPPACCT.NO_DUE_DAYS,
        BLINFHDR.AT_TOT_NET
FROM    CL2PRP.DB_ACTIVITY             DBACTVY,
        CL2PRP.BILL_INFO_HDR           BLINFHDR,
        CL2PRP.SUPPLIER_ACCOUNT        SUPPACCT
WHERE   SUPPACCT.KY_SUPPLIER_ID     =   'MC2'
  AND     DBACTVY.KY_BA               =   BLINFHDR.KY_BA
  AND     DBACTVY.DT_BILL             =   BLINFHDR.DT_STAT
  AND     DBACTVY.KY_BA               =   SUPPACCT.KY_BA
  AND     DBACTVY.AT_REMN_DB          >   0
--  AND     (TRUNC(SYSDATE) - TO_DATE(BLINFHDR.DT_DUE,'YYYY-MM-DD'))  >=  7
  AND     SYSDATE - TO_DATE(BLINFHDR.DT_DUE,'YYYY-MM-DD')  >=  7
/

@utlxpls.sql