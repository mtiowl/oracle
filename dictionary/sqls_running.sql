set linesize 300
set pagesize 100
col username format a10
col service_name format a20
col module format a20
col program format a40
col machine format a30
col sid format 99999

select username, s.sid, s.status
      --,s.service_name
      ,s.module, s.program, s.machine, s.sql_id, round(longops.pct_complete,2) pct_complete
      ,longops.min_running, longops.MIN_TO_COMP time_remaining_min, substr(sql.sql_text,1,50) sql_text
  from v$session s
      ,v$sql sql
      ,v$sesstat stat
      ,(select s.sid, s.sql_id, (sofar/totalwork)*100 pct_complete, sofar, totalwork
              , to_char(l.start_time, 'HH24:MI:SS') Started
              ,round( (sysdate-l.start_time)*24*60,2) MIN_RUNNING
              ,round((((sysdate-l.start_time)*24*60)*l.totalwork/l.sofar)-((sysdate-l.start_time)*24*60),2) MIN_TO_COMP
              --,l.ELAPSED_SECONDS
              --,l.TIME_REMAINING
          from v$session_longops l
              ,v$session s
          where l.sid = s.sid
            and (upper(machine) like 'LNX-MSTR-5T%' or upper(machine) like 'LNX-MSTR-3P%')
            --and (sofar/totalwork)*100 < 100
            ) longops
  where s.sid = longops.sid(+)
    and s.sql_id = longops.sql_id(+)
    and s.sql_id = sql.sql_id
    and s.sid = stat.sid
    and (upper(machine) like 'LNX-MSTR-5T%' or upper(machine) like 'LNX-MSTR-3P%')
    and (sofar/totalwork)*100 < 100
  order by s.status
/