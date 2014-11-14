col job_name format a20
col job_mode format a20
col state format a11
col operation format a10
set linesize 300

select * from dba_datapump_jobs
/

SELECT o.status, o.object_id, o.object_type, 
       o.owner||'.'||object_name "OWNER.OBJECT"
  FROM dba_objects o, dba_datapump_jobs j
 WHERE o.owner=j.owner_name AND o.object_name=j.job_name
   AND j.job_name NOT LIKE 'BIN$%' 
 ORDER BY 4,2;

set linesize 100


set serveroutput on size 1000000
DECLARE
  ind NUMBER;              -- Loop index
  h1 NUMBER;               -- Data Pump job handle
  percent_done NUMBER;     -- Percentage of job complete
  job_state VARCHAR2(30);  -- To keep track of job state
  js ku$_JobStatus;        -- The job status from get_status
  ws ku$_WorkerStatusList; -- Worker status
  sts ku$_Status;          -- The status object returned by get_status
  le ku$_LogEntry;         -- For WIP and error messages

BEGIN

h1 := DBMS_DATAPUMP.attach('&job_name', USER); -- job name and owner
dbms_datapump.get_status(h1,
           dbms_datapump.ku$_status_job_error +
           dbms_datapump.ku$_status_job_status +
           dbms_datapump.ku$_status_wip, 0, job_state, sts);
js := sts.job_status;
ws := js.worker_status_list;

dbms_output.put_line('*** Job percent done = ' ||to_char(js.percent_done));
dbms_output.put_line('restarts - '||js.restart_count);
dbms_output.put_line('mask: '||sts.mask);

ind := ws.first;

while ind is not null loop
    dbms_output.put_line('rows completed - '||ws(ind).completed_rows);
    ind := ws.next(ind);
end loop;



   if (bitand(sts.mask,dbms_datapump.ku$_status_wip) != 0) then
      le := sts.wip;
   else
      if (bitand(sts.mask,dbms_datapump.ku$_status_job_error) != 0) then
        le := sts.error;
      else
        le := null;
      end if;
    end if;
    
    if le is not null then
      ind := le.FIRST;
      while ind is not null loop
        dbms_output.put_line(le(ind).LogText);
        ind := le.NEXT(ind);
      end loop;
    end if;


DBMS_DATAPUMP.detach(h1);
end;
/