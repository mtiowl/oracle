--  start h:\sql\u\sql_by_hour.txt

define first_snap='&1' 
define  last_snap='&2' 
define how_many_sqls='&3'

ttitle off
clear columns breaks computes
col starting    format a11
col report_time format a16
set trimspool on
set tab       off
set verify    off

/*--------------------------------------------------------*/
/*   Get Name of Database - for spool report name         */
/*--------------------------------------------------------*/
col uppername format a8 noprint new_value upperdb
select UPPER(name) uppername from v$database;

/*--------------------------------------------------------*/
/*   FIND COUNTS FOR ALL SQLS                             */
/*--------------------------------------------------------*/
start  includes/sql9_by_hour_all_sqls.sql
exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_ALL')

/*--------------------------------------------------------*/
/*   FIND TOP SQL BY BUFFER_GETS                          */
/*--------------------------------------------------------*/
create table temporary_sql_buffer_gets pctfree 0 nologging as
select rownum rank, a.* from (
       select * from temporary_sql_all_by_hash
        order by buffer_gets DESC) a
 where rownum<=&how_many_sqls;

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_BUFFER_GETS')

/*--------------------------------------------------------*/
/*   FIND TOP SQL BY DISK_READS                           */
/*--------------------------------------------------------*/
create table temporary_sql_disk_reads pctfree 0 nologging as
select rownum rank, a.* from (
       select * from temporary_sql_all_by_hash
        order by disk_reads DESC) a
 where rownum<=&how_many_sqls;

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_DISK_READS')

/*--------------------------------------------------------*/
/*   FIND TOP SQL BY CPU                                  */
/*--------------------------------------------------------*/
create table temporary_sql_cpu pctfree 0 nologging as
select rownum rank, a.* from (
       select * from temporary_sql_all_by_hash
        order by cpu DESC) a
 where rownum<=&how_many_sqls;

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_CPU')

/*--------------------------------------------------------*/
/*   GENERATE A SQL "START" FOR EACH HASH VALUE           */
/*--------------------------------------------------------*/
set pagesize 0
set feedback off
set termout  off
spool %temp%\sql_by_hour_gen.lst
select 'start includes/sql9_by_hour_one_sql.sql '||to_char(hash_value)
  from (select DISTINCT hash_value from 
             (select hash_value from temporary_sql_buffer_gets
               UNION
              select hash_value from temporary_sql_disk_reads
               UNION
              select hash_value from temporary_sql_cpu))
 order by hash_value;
spool off
set termout on
set pagesize 60

/*--------------------------------------------------------*/
/*   REPORT HOURLY STATISTICS FOR THESE BIG SQLS          */
/*--------------------------------------------------------*/
spool H:\Oracle\DBA\Snapshots\sql_by_hour_&&upperdb..lst
col    host_name format a12
col    startup   format a16

select d.name,      '&HOW_MANY_SQLS LARGEST SQLS' REPORT,
      &FIRST_SNAP first_snap, &LAST_SNAP last_snap,
       to_char(sysdate,'YYYY-MM-DD HH24:MI') REPORT_TIME
  from v$database d, v$instance i;

select version, host_name,
       to_char(startup_time,'YYYY-MM-DD HH24:MI') STARTUP
  from v$database d, v$instance i;

set pagesize 0
select ' ' from dual;

select to_char(snap_time,'YYYY-MM-DD HH24:MI'), 'FIRST SNAPSHOT', &FIRST_SNAP
  from stats$snapshot
 where snap_id=(select MIN(snap_id)
                  from stats$snapshot
                 where snap_id>=&FIRST_SNAP)
UNION
select to_char(snap_time,'YYYY-MM-DD HH24:MI'), ' LAST SNAPSHOT', &LAST_SNAP
  from stats$snapshot
 where snap_id=(select MAX(snap_id)
                  from stats$snapshot
                 where snap_id<=&LAST_SNAP);

/*--------------------------------------------------------*/
/*   REPORT                                               */
/*--------------------------------------------------------*/
set linesize 100
set pagesize 60

clear breaks columns computes
col sqls        format 99990
col mins        format  9990
col cpu         format 99990
col elapsed     format 999990
col executions  format 99999990 head "EXECS"
col buffer_gets format 9,999,999,990
col disk_reads  format 999,999,990
col processed   format 999,999,990
col rank        format 990
col buff_hit    format 990.0


/*--------------------------------------------------------*/
/*   TOP SQLS - ALL                                       */
/*--------------------------------------------------------*/
break on report
compute sum of cpu         on report
compute sum of elapsed     on report
compute sum of executions  on report
compute sum of buffer_gets on report
compute sum of disk_reads  on report
compute sum of processed   on report
compute sum of rows_processed on report

select to_char(begin_time,'MM/DD HH24:MI') starting,
       count(*)            sqls,
       sum(buffer_gets)    buffer_gets,
       sum(disk_reads)     disk_reads,
       sum(rows_processed) processed,
       sum(cpu)            cpu,
       sum(elapsed)        elapsed,
       (1-sum(disk_reads)/GREATEST(1,sum(buffer_gets)))*100 buff_hit
  from temporary_sql_all
 group by to_char(begin_time,'MM/DD HH24:MI')
 order by 1;


/*--------------------------------------------------------*/
/*   TOP SQLS - BUFFER GETS                               */
/*--------------------------------------------------------*/
ttitle LEFT 'Top SQLs by BUFFER GETS' SKIP ' '
select rank,
       buffer_gets,
       ROUND(buffer_gets/GREATEST(1,executions)) "GETS/EXEC",
       executions,
       disk_reads,
       rows_processed processed,
       cpu,
       elapsed,
       hash_value 
  from temporary_sql_buffer_gets
 order by buffer_gets DESC;

/*--------------------------------------------------------*/
/*   TOP SQLS - DISK READS                                */
/*--------------------------------------------------------*/
ttitle LEFT 'Top SQLs by DISK READS' SKIP ' '
select rank,
       disk_reads,
       ROUND(disk_reads/GREATEST(1,executions)) "READS/EXEC",
       executions,
       buffer_gets,
       rows_processed processed,
       cpu,
       elapsed,
       hash_value 
  from temporary_sql_disk_reads
 order by disk_reads DESC;

/*--------------------------------------------------------*/
/*   TOP SQLS - CPU                                       */
/*--------------------------------------------------------*/
ttitle LEFT 'Top SQLs by CPU' SKIP ' '
select rank,
       cpu,
       elapsed,
       disk_reads,
       ROUND(disk_reads/GREATEST(1,executions)) "READS/EXEC",
       executions,
       buffer_gets,
       rows_processed processed,
       hash_value 
  from temporary_sql_cpu
 order by cpu DESC;

ttitle off

start %temp%\sql_by_hour_gen.lst

spool off

drop table temporary_sql_all;
drop table temporary_sql_all_by_hash;
drop table temporary_sql_buffer_gets;
drop table temporary_sql_disk_reads;
drop table temporary_sql_cpu;

