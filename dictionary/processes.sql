@whoami

set linesize 300
set pagesize 100
break on report

col PROGRAM format a50
col uppername format a8 noprint new_value upperdb
select UPPER(name) uppername from v$database;


spool c:\temp\sessions_&&upperdb..out


prompt Historical Max Current Logins (From Snapshots)
-- For more stats:  http://docs.oracle.com/cd/B12037_01/server.101/b10755/stats002.htm
-- Doesn't tell you how many processes, but you can use these counts assuming 1 process for each session
-- Also, the snapshot may miss the point in time when Oracle hits the max session (Ora-00020) error.

select trunc(a.begin_interval_time) "Date"
      ,to_char(a.begin_interval_time, 'Day') "Day of Week"
      ,max(b.value) sessions
  from dba_hist_snapshot a
      ,dba_hist_sysstat b 
  where a.snap_id = b.snap_id 
    and b.stat_name = 'logons current' 
    and a.begin_interval_time > sysdate-14
    and trunc(a.begin_interval_time) <> trunc(sysdate)
  group by trunc(a.begin_interval_time)
          ,to_char(a.begin_interval_time, 'Day')
  order by 1
/


Prompt The following shows current processes and sessions

compute sum of count(*) on report

select username, terminal, program, count(*)
from v$process
group by username, terminal, program
/

select osuser, username, program, count(*)
from v$session
group by osuser, username, program
/
  
col name format a30
col value format a30
select name, value from v$parameter where UPPER(name) in ('SESSIONS', 'PROCESSES')
/

set linesize 100
clear breaks

@cpu_by_session.sql

spool off