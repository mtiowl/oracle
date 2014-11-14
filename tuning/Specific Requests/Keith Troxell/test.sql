-- OLD
SELECT ky_pnd_seq_trans, ky_supplier, cd_tran_status,
       id_edc_duns, id_edc_acct_num, id_ba_esco, ky_ba,
       ky_enroll, id_trans_ref_num_867, id_trans_ref_num_810,
       cd_tran_type_867, ky_row_seq_trans_810, dt_period_start,
       dt_period_end, cd_purpose, cd_fault_reason,
       fl_solution_fault, cd_bill_type, cd_bill_calc_method,
       dt_doc_due, fl_retag, fl_internal_rebill, cd_final,
       cd_service, tx_comment, ts_sent_to_css, dt_billed_by_css,
       ts_last_updated, ts_created, ts_idr_start, ts_idr_end
  FROM custpro.cpm_pnd_tran_hdr
  -- Select all of the headers for any KY_BA that had activity in the past 7 days
  -- We need to select all, since CANC transactions need to go back to the original BILL record
  --
  --where (ky_ba, dt_period_start, dt_period_end) in
  --            (select ky_ba, dt_period_start, dt_period_end
  --              from  custpro.cpm_pnd_tran_hdr
  --             where dt_billed_by_css >= trunc(sysdate-7) ) 
  where ky_ba in (select ky_ba
                    from  custpro.cpm_pnd_tran_hdr
                    where dt_billed_by_css >= trunc(sysdate-7) ) 

/