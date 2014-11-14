select ky_ba, 
       X.KY_BA_LEAD_ZEROS, 
       x.ky_old_acctno, 
       x.ky_supplier_id, 
       ky_enroll, 
       AT_TOT_deferred_TO_DATE, 
       KY_CPM_BUDGET_BILL_HIST
--       ,max(case 
--              when x.ky_supplier_id in ('BGEHOME', 'GEXA3','EPLUS','AMERIGREEN', 'XOOM') then KY_CPM_BUDGET_BILL_HIST 
--           end) 
--       over (partition by ky_enroll) MaxBudgetRecord
  from CUSTPRO.CPM_BUDGET_BILL_HIST
      ,PVIEW.CSS_ER_XREF_CUST_INFO x
  where ky_enroll = x.ky_old_acctno
    and x.ky_supplier_id in ('BGEHOME', 'GEXA3','EPLUS','AMERIGREEN', 'XOOM')
/

SELECT bill.ky_enroll, max(KY_CPM_BUDGET_BILL_HIST) ky_cpm_budget_bill_hist
         FROM bill_hdr bill
             ,CPM_BUDGET_BILL_HIST bbh2
         WHERE bill.ky_supplier in ('BGEHOME', 'GEXA3','EPLUS','AMERIGREEN', 'XOOM')
           AND bill.ky_bill = bbh2.ky_bill
         GROUP BY bill.ky_enroll
/

SELECT xref.KY_BA_LEAD_ZEROS
      ,xref.ky_old_acctno
      ,xref.ky_supplier_id
      ,bbh.ky_cpm_budget_bill_hist
      ,bbh.AT_TOT_deferred_TO_DATE
  FROM pview.css_er_xref_cust_info xref
      ,cpm_budget_bill_hist bbh
      ,(SELECT bill.ky_enroll, max(KY_CPM_BUDGET_BILL_HIST) ky_cpm_budget_bill_hist
         FROM bill_hdr bill
             ,CPM_BUDGET_BILL_HIST bbh2
         WHERE bill.ky_supplier in ('BGEHOME', 'GEXA3','EPLUS','AMERIGREEN', 'XOOM')
           AND bill.ky_bill = bbh2.ky_bill
         GROUP BY bill.ky_enroll) deferredAmt
  WHERE xref.ky_old_acctno = bbh.ky_enroll
    AND bbh.ky_cpm_budget_bill_hist = deferredAmt.ky_cpm_budget_bill_hist
/