set autotrace off
set linesize 90
set verify off
col stats format a8
col execs format 9999990
col gets  format 9,999,999,990
col reads format 9,999,999,990
col times head 'FIRST/LAST TIMES' format a19
select 'TOTAL   ' STATS,
       executions execs, buffer_gets gets, disk_reads reads,
       rows_processed, 
       substr(first_load_time,01,10)||' '||
       substr(first_load_time,12,08) TIMES
  from v$sqlarea
 where sql_id='&1'
UNION
select 'PER EXEC',1,ROUND(buffer_gets/greatest(1,executions)),
       ROUND(disk_reads/greatest(1,executions)),
       ROUND(rows_processed/greatest(1,executions)),
       to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') 
  from v$sqlarea
 where sql_id='&1'
order by 1 DESC;

