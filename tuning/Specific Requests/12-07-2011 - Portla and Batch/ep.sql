REM set timing on;
REM SHOW PARAMETER OPTIMIZER_MODE

SET SCAN OFF

alter session set optimizer_mode = CHOOSE;
--alter session set optimizer_mode = RULE;



DELETE plan_table where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO plan_table
  FOR
SELECT DISTINCT a.KY_SUPPLIER_ID "Supplier", a.TX_SERV_SUPP EDC, a.CSS_NAME "Customer Name", CUST.TX_CONTRACT_NAME "Contract Name", a.KY_BA "Bill Account", a.KY_OLD_ACCTNO "ER Number", d.TX_UTILITY_ACCOUNT "Utility Account Number", CUST.CD_ACCOUNT_SUB_TYPE "Account Sub-Type", e.TX_DECODE "Summary Billing Group", c.TX_DECODE "Salesperson", trunc(sysdate) - ER_DT_SERVICE_START "Number of Unbilled Days", a.CSS_LASTUSAGEEND "Usage End Date", a.DT_LST_BLLD "Date Last Billed", a.ER_DT_SERVICE_START "Service Start Date", a.CSS_BILL_OPTION "Bill Option", TRUNC(SYSDATE) "Run Date", CUST.CD_PRODUCT "Product", CPTH.CD_FINAL "Final Indicator", DECODE(a.ER_CD_RGSTRTN_STATUS, 'PFNL', 'TRUE', 'FALSE') "Pending Drop?", DC.DT_DROP_EFFECTIVE "Drop Effective Date", DECODE(a.TX_SERV_SUPP, 'Central Hudson Gas &', 'Y', 'N/A') "BiMonthlyBilling", SUM(QY_QUANTITY) "Actual Usage", DECODE(TRIM(CPTH3.CD_TRAN_STATUS), NULL, 'Missing 810 & 867', '20', 'Unmatched 810/867', '65', 'Scheduled for Billing', 'Research Account in BTI') "Billing Status", CPTH3.DT_PERIOD_START, CPTH3.DT_PERIOD_END, NULL "Comments", 'Never Billed' "FL_NOT_NEVER", 0 "Processed?", 'FALSE' "Exists in Oracle"
FROM PVIEW.CSS_ER_XREF_CUST_INFO a LEFT JOIN
(SELECT MAX(DT_DROP_EFFECTIVE) "DT_DROP_EFFECTIVE", KY_ENROLL
FROM PVIEW.DROP_CUSTOMER GROUP BY KY_ENROLL) DC ON DC.KY_ENROLL = a.KY_OLD_ACCTNO LEFT JOIN CUSTPRO.CPM_PND_TRAN_HDR CPTH ON CPTH.KY_ENROLL = a.KY_OLD_ACCTNO AND CPTH.CD_FINAL = 'F' LEFT JOIN
(SELECT MAX(KY_PND_SEQ_TRANS) KY_PND_SEQ_TRANS, KY_ENROLL
FROM CUSTPRO.CPM_PND_TRAN_HDR CPTH2
WHERE CPTH2.CD_TRAN_STATUS NOT IN ('75', '99') AND CPTH2.CD_PURPOSE = '00' GROUP BY KY_ENROLL) CPTHT ON CPTHT.KY_ENROLL = a.KY_OLD_ACCTNO LEFT JOIN CUSTPRO.CPM_PND_TRAN_HDR CPTH3 ON CPTH3.KY_PND_SEQ_TRANS = CPTHT.KY_PND_SEQ_TRANS LEFT JOIN CUSTPRO.CPM_PND_MONTHLY_867 CPM8 ON CPTH3.KY_PND_SEQ_TRANS = CPM8.KY_PND_SEQ_TRANS AND CPM8.FL_SEND_TO_CSS = 'Y', PVIEW.ENROLL b, PVIEW.BILL_ACCOUNT BA LEFT JOIN PVIEW.CODE e ON BA.KY_AFFINITY = e.KY_CODE AND e.KY_TABLE = 'CSS_AFFINITY_GROUP' AND e.KY_SUPPLIER = 'BGEHOME', PVIEW.CODE c, PVIEW.ACCOUNT d, ERADMIN.CUSTOMER@ERSP CUST
WHERE a.KY_OLD_ACCTNO = b.KY_ENROLL AND a.KY_OLD_ACCTNO = CUST.KY_ER_REF_ID AND b.KY_ACCOUNT_MANAGER = c.KY_CODE AND d.KY_ENROLL = a.KY_OLD_ACCTNO AND BA.KY_ENROLL = a.KY_OLD_ACCTNO AND c.KY_TABLE = 'MRKT_SEGMENT' AND c.KY_SUPPLIER = 'BGEHOME' AND (a.ER_DT_SERVICE_START < trunc(sysdate) - 40 AND a.DT_LST_BLLD Is Null OR a.ER_DT_SERVICE_START < trunc(sysdate) - 40 AND a.DT_LST_BLLD < a.ER_DT_SERVICE_START) AND NVL(a.er_cd_utility_program, ' ') <> 'NOPE' AND a.CSS_STATUS = 'Active' AND a.KY_SUPPLIER_ID = 'BGEHOME' AND d.TX_UTILITY_ACCOUNT <> '99999999999999111' GROUP BY a.TX_SERV_SUPP, a.CSS_NAME, a.KY_BA, a.KY_SUPPLIER_ID, a.KY_OLD_ACCTNO, d.TX_UTILITY_ACCOUNT, c.TX_DECODE, CPTH3.CD_TRAN_STATUS, a.CSS_LASTUSAGEEND, a.DT_LST_BLLD, a.ER_DT_SERVICE_START, a.CSS_BILL_OPTION, CPTH.CD_FINAL, a.ER_CD_RGSTRTN_STATUS, e.TX_DECODE, dc.DT_DROP_EFFECTIVE, DT_PERIOD_START, DT_PERIOD_END, CUST.CD_PRODUCT, CUST.TX_CONTRACT_NAME, CUST.CD_ACCOUNT_SUB_TYPE union all
SELECT DISTINCT a.KY_SUPPLIER_ID "Supplier", a.TX_SERV_SUPP EDC, a.CSS_NAME "Customer Name", CUST.TX_CONTRACT_NAME "Contract Name", a.KY_BA "Bill Account", a.KY_OLD_ACCTNO "ER Number", d.TX_UTILITY_ACCOUNT "Utility Account Number", CUST.CD_ACCOUNT_SUB_TYPE "Account Sub-Type", e.TX_DECODE "Summary Billing Group", c.TX_DECODE "Salesperson", trunc(sysdate) - CSS_LASTUSAGEEND "Number of Unbilled Days", a.CSS_LASTUSAGEEND "Usage End Date", a.DT_LST_BLLD "Date Last Billed", a.ER_DT_SERVICE_START "Service Start Date", a.CSS_BILL_OPTION "Bill Option", TRUNC(SYSDATE) "Run Date", CUST.CD_PRODUCT "Product", CPTH.CD_FINAL "Final Indicator", DECODE(a.ER_CD_RGSTRTN_STATUS, 'PFNL', 'TRUE', 'FALSE') "Pending Drop?", DC.DT_DROP_EFFECTIVE "Drop Effective Date", DECODE(a.TX_SERV_SUPP, 'Central Hudson Gas &', 'Y', 'N/A') "BiMonthlyBilling", SUM(QY_QUANTITY) "Actual Usage", DECODE(TRIM(CPTH3.CD_TRAN_STATUS), NULL, 'Missing 810 & 867', '20', 'Unmatched 810/867', '65', 'Scheduled for Billing', 'Research Account in BTI') "Billing Status", CPTH3.DT_PERIOD_START, CPTH3.DT_PERIOD_END, NULL "Comments", 'Not Billed' "FL_NOT_NEVER", 0 "Processed?", 'FALSE' "Exists in Oracle"
FROM PVIEW.CSS_ER_XREF_CUST_INFO a LEFT JOIN
(SELECT MAX(DT_DROP_EFFECTIVE) "DT_DROP_EFFECTIVE", KY_ENROLL
FROM PVIEW.DROP_CUSTOMER GROUP BY KY_ENROLL) DC ON DC.KY_ENROLL = a.KY_OLD_ACCTNO LEFT JOIN CUSTPRO.CPM_PND_TRAN_HDR CPTH ON CPTH.KY_ENROLL = a.KY_OLD_ACCTNO AND CPTH.CD_FINAL = 'F' LEFT JOIN
(SELECT MAX(KY_PND_SEQ_TRANS) KY_PND_SEQ_TRANS, KY_ENROLL
FROM CUSTPRO.CPM_PND_TRAN_HDR CPTH2
WHERE CPTH2.CD_TRAN_STATUS NOT IN ('75', '99') AND CPTH2.CD_PURPOSE = '00' GROUP BY KY_ENROLL) CPTHT ON CPTHT.KY_ENROLL = a.KY_OLD_ACCTNO LEFT JOIN CUSTPRO.CPM_PND_TRAN_HDR CPTH3 ON CPTH3.KY_PND_SEQ_TRANS = CPTHT.KY_PND_SEQ_TRANS LEFT JOIN CUSTPRO.CPM_PND_MONTHLY_867 CPM8 ON CPTH3.KY_PND_SEQ_TRANS = CPM8.KY_PND_SEQ_TRANS AND CPM8.FL_SEND_TO_CSS = 'Y', PVIEW.ENROLL b, PVIEW.BILL_ACCOUNT BA LEFT JOIN PVIEW.CODE e ON BA.KY_AFFINITY = e.KY_CODE AND e.KY_TABLE = 'CSS_AFFINITY_GROUP' AND e.KY_SUPPLIER = 'BGEHOME', PVIEW.CODE c, PVIEW.ACCOUNT d, ERADMIN.CUSTOMER@ERSP CUST
WHERE a.KY_OLD_ACCTNO = b.KY_ENROLL AND a.KY_OLD_ACCTNO = CUST.KY_ER_REF_ID AND b.KY_ACCOUNT_MANAGER = c.KY_CODE AND d.KY_ENROLL = a.KY_OLD_ACCTNO AND BA.KY_ENROLL = a.KY_OLD_ACCTNO AND c.KY_TABLE = 'MRKT_SEGMENT' AND c.KY_SUPPLIER = 'BGEHOME' AND a.CSS_STATUS = 'Active' AND a.CSS_LASTUSAGEEND <= trunc(sysdate) - 40 AND a.DT_LST_BLLD Is NOT Null AND a.CSS_LASTUSAGEEND > a.ER_DT_SERVICE_START AND a.KY_SUPPLIER_ID In('BGEHOME') AND NVL(a.er_cd_utility_program, ' ') <> 'NOPE' AND d.TX_UTILITY_ACCOUNT <> '99999999999999111' GROUP BY a.TX_SERV_SUPP, a.CSS_NAME, a.KY_BA, a.KY_SUPPLIER_ID, a.KY_OLD_ACCTNO, d.TX_UTILITY_ACCOUNT, c.TX_DECODE, CPTH3.CD_TRAN_STATUS, a.CSS_LASTUSAGEEND, a.DT_LST_BLLD, a.ER_DT_SERVICE_START, a.CSS_BILL_OPTION, CPTH.CD_FINAL, a.ER_CD_RGSTRTN_STATUS, e.TX_DECODE, dc.DT_DROP_EFFECTIVE, DT_PERIOD_START, DT_PERIOD_END, CUST.CD_PRODUCT, CUST.TX_CONTRACT_NAME, CUST.CD_ACCOUNT_SUB_TYPE
/

@utlxpls.sql