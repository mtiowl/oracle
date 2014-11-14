begin
   dbms_job.remove(&job_id);
   commit;
end;
/
