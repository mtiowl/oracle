set timing on;
SHOW PARAMETER OPTIMIZER_MODE


--alter session set optimizer_mode = CHOOSE;
alter session set optimizer_mode = RULE;



DELETE sqln_explain_plan where statement_id = 'MTI'
/

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO sqln_explain_plan
  FOR
select sup.cd_settle_type 
      ,pth.ky_pnd_seq_trans 
      ,pth.ky_enroll 
      ,pth.ts_last_updated 
      ,pth.dt_period_start  settlement_start 
      ,pth.dt_period_end    settlement_end 
      ,status.tx_description||' ('||pth.cd_tran_status||')' as tran_status 
      ,state.tx_state 
      ,substr(sup.tx_settle_yyyymm, 5, 2) as settle_month 
      ,substr(sup.tx_settle_yyyymm, 1, 4) as settle_year 
      ,REPLACE (sup.tx_contract_name, '''', '''''') as contract_name 
      ,sup.tx_client_acctno as client_acct_no 
      ,REPLACE (sup.tx_css_name, '''', '''''') as tx_css_name 
      ,sup.id_edc_acct_num 
      ,sup.cd_serv_supp 
      ,sup.cd_iso 
      ,NVL(sup.at_settle_charge, 0) as at_settle_charge  
      ,NVL(sup.at_settle_charge_on_pk,0) as at_settle_charge_on_pk  
      ,NVL(sup.at_settle_charge_off_pk,0) as at_settle_charge_off_pk  
      ,sup.tx_settle_comment  
      ,sup.fl_err_override  
      ,NVL(sup.fl_need_export, 'Y') fl_need_export 
      ,NVL(sup.tx_source_doc,'No Value') tx_source_doc 
      ,NVL(sup.ts_updated, '31-DEC-9999') ts_updated 
      ,NVL(sup.dt_all_subs_billed, '31-DEC-9999') dt_all_subs_billed 
      ,NVL(sup.dt_post_date, '31-DEC-9999') dt_post_date 
      ,NVL(sup.cd_band_status, 'No Value') cd_band_status 
      ,NVL(sup.cd_deal_type, 'No Value') cd_deal_type 
      ,NVL(sup.qy_child_count, -1) qy_child_count 
      ,NVL(sup.cd_completion_status, 'No Value') cd_completion_status 
      ,aggh.cd_agg_type 
      ,TRUNC(aggmember.dt_eff_from) as dt_eff_from 
      ,TRUNC(aggmember.dt_eff_to) as dt_eff_to 
      ,aggh.tx_agg_value as affinity 
    FROM custpro.cpm_pnd_settlement_supp sup 
        ,custpro.cpm_pnd_tran_hdr pth 
        ,custpro.cpm_agg_member aggmember 
        ,custpro.cpm_agg_header aggh 
        ,custpro.cpm_edc_state state  
        ,custpro.cpm_cd_tran_status status  
    where sup.ky_pnd_seq_trans = pth.ky_pnd_seq_trans  
      and pth.ky_enroll = aggmember.ky_enroll  
      and aggmember.cd_member_type = 'MASTER'  
      and aggmember.ky_cpm_agg_header = aggh.ky_cpm_agg_header  
      and aggmember.dt_eff_from <= pth.dt_period_end  
      and aggmember.dt_eff_to >= pth.dt_period_start  
      AND state.cd_serv_supp = sup.cd_serv_supp  
      AND pth.cd_tran_status NOT IN ('58', '75')  
      AND pth.cd_tran_status = status.cd_tran_status  
      AND sup.cd_settle_type = 'STLBAND' 
      AND pth.dt_period_start = to_date('01-DEC-2010', 'DD-MON-YYYY') 
      AND pth.dt_period_end = to_date('31-DEC-2010', 'DD-MON-YYYY') 
/

@utlxpls.sql