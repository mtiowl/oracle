column what format a20
select sysdate, job, what, last_date, next_date, broken 
  from dba_jobs
  where what = '%MTI_TEST%'
/
