DELETE sqln_explain_plan where statement_id = 'MTI'
/

REM /*+ INDEX (master CPM_AGG_MEMBER_TYPE_I) */ 

EXPLAIN PLAN
  SET STATEMENT_ID = 'MTI'
  INTO sqln_explain_plan
  FOR
     select 
            pth.ky_enroll
           ,pth.ky_pnd_seq_trans
           ,pth.dt_period_start      master_start
           ,pth.dt_period_end        master_end
           ,pth.cd_tran_type_867
           ,master.dt_eff_from       master_agg_start
           ,master.dt_eff_to         master_agg_end
           ,sub.dt_eff_from          sub_agg_start
           ,sub.dt_eff_to            sub_agg_end
           ,sub_tran.ky_enroll       child_enroll
           ,sub_tran.dt_period_start sub_period_start
           ,sub_tran.dt_period_end   sub_period_end
       from cpm_pnd_tran_hdr pth
           ,cpm_agg_member master
           ,cpm_agg_member sub
           ,cpm_pnd_tran_hdr sub_tran
       where pth.cd_tran_type_867 = 'STL'
         and master.ky_enroll = pth.ky_enroll
         and master.cd_member_type = 'MASTER'
         and sub.ky_cpm_agg_header = master.ky_cpm_agg_header
         --
         -- Make sure the aggregation Master and Sub are active during the month
         --
         and master.dt_eff_from <= pth.dt_period_start
         and master.dt_eff_to >= pth.dt_period_end
         and sub.dt_eff_from <= pth.dt_period_start
         and sub.dt_eff_to >= pth.dt_period_end
         --
         -- Get all of the effected master records based on the aggregation memeber's
         -- CACNEL date
         --
         and (     (sub_tran.dt_period_start >= pth.dt_period_start AND sub_tran.dt_period_start <= pth.dt_period_end)
                OR (sub_tran.dt_period_end   >= pth.dt_period_start AND sub_tran.dt_period_end   <= pth.dt_period_end)
                OR (sub_tran.dt_period_start <= pth.dt_period_start AND sub_tran.dt_period_end   >= pth.dt_period_end))
         and sub.cd_member_type = 'SUB'
         and sub.ky_enroll = sub_tran.ky_enroll
         and sub_tran.ky_enroll = 1556483
         and sub_tran.ky_pnd_seq_trans = 3758143
         and sub.ky_cpm_agg_header = 1049977

/


spool explain.out
@utlxpls.sql
spool off