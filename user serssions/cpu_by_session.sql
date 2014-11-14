set linesize 399
col value format 999999999

col uppername format a8 noprint new_value upperdb
select UPPER(name) uppername from v$database;


PROMPT Sessions that have used more than 2 CPU minutes (&&upperdb)
SELECT s.sid session_id, s.osuser, s.username, s.program, round(ss.value/100) "CPU Seconds"
      --,n.name, n.class
 FROM v$sesstat ss
     ,v$session s
     , v$statname n
 WHERE ss.statistic# = 12
   AND s.sid = ss.sid
   AND n.statistic# = ss.statistic#
   AND round(ss.value/100) >= 120
 order by ss.value desc
/

set linesize 100