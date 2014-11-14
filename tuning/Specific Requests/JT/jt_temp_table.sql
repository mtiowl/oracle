select count(a.ky_enroll) erCount
     , a.ky_transaction_type
     , a.ky_supplier
 from PVIEW.goodwrench_import_archive a
 where a.dt_processed >= sysdate - 180 
   and a.fl_process = 'Y'
group by a.ky_transaction_type, a.ky_supplier 


CREATE mti_test INDEX on goodwrench_import_archive (fl_process, dt_processed)
  TABLESPACE pgoodwrench;
  
CREATE INDEX mti_test on goodwrench_import_archive (fl_process, dt_processed) tablespace pview_data
    storage(initial 16m next 16m) parallel 2
/

DROP TABLE jt_temp;
CREATE TABLE jt_temp AS 
select ky_transaction_type
     , ky_supplier
     ,dt_processed
 from goodwrench_import_archive 
 where dt_processed >= sysdate - 180 
   and fl_process = 'Y'
   and ky_transaction_type in('CPA','CPT','CPTA','CPU','DADM') 
/