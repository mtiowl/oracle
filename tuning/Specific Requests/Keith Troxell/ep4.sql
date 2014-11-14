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
SELECT ky_pnd_seq_trans
      ,ky_supplier
      ,cd_tran_status
      ,id_edc_duns
      ,id_edc_acct_num
      ,id_ba_esco
      ,pth.ky_ba
      ,ky_enroll
      ,id_trans_ref_num_867
      ,id_trans_ref_num_810
      ,cd_tran_type_867
      ,ky_row_seq_trans_810
      ,pth.dt_period_start
      ,pth.dt_period_end
      ,cd_purpose
      ,cd_fault_reason
      ,fl_solution_fault
      ,cd_bill_type
      ,cd_bill_calc_method
      ,dt_doc_due
      ,fl_retag
      ,fl_internal_rebill
      ,cd_final
      ,cd_service
      ,tx_comment
      ,ts_sent_to_css
      ,dt_billed_by_css
      ,ts_last_updated
      ,ts_created
      ,ts_idr_start
      ,ts_idr_end
  FROM custpro.cpm_pnd_tran_hdr pth
      ,(select ky_ba, dt_period_start, dt_period_end
          from  custpro.cpm_pnd_tran_hdr
          where dt_billed_by_css >= trunc(sysdate-7) ) trans
  -- Select all of the headers for any KY_BA that had activity in the past 7 days
  -- We need to select all, since CANC transactions need to go back to the original BILL record
  where pth.ky_ba = trans.ky_ba
    AND pth.dt_period_start = trans.dt_period_start
    AND pth.dt_period_end = trans.dt_period_end
/

@utlxpls.sql