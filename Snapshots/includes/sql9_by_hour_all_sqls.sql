--     h:\sql\u\sql_by_hour_all_sqls.sql

create table temporary_sql_all pctfree 0 nologging
       storage(initial 1M next 256K) as
select bb.hash_value, ss.begin_time, ss.end_time,
       GREATEST(0,ee.executions -bb.executions ) executions,
       GREATEST(0,ee.buffer_gets-bb.buffer_gets) buffer_gets,
       GREATEST(0,ee.disk_reads -bb.disk_reads ) disk_reads,
       GREATEST(0,ee.rows_processed-bb.rows_processed) rows_processed,
       GREATEST(0,ee.cpu        -bb.cpu        ) cpu,
       GREATEST(0,ee.elapsed    -bb.elapsed    ) elapsed,
       ee.module
  from 
(select b.snap_id b_id, b.snap_time begin_time,
        e.snap_id e_id, e.snap_time end_time
  from (select snap_id,snap_time,rownum rank from 
       (select snap_id,snap_time from stats$snapshot
         where snap_id between &first_snap and &last_snap)) b,
       (select snap_id,snap_time,rownum-1 rank from 
       (select snap_id,snap_time from stats$snapshot
         where snap_id between &first_snap and &last_snap)) e
 where b.rank=e.rank
  order by b.snap_id) ss,
-- ---------------------------------------------------     begin stats
(select snap_id,hash_value,
        ROUND(cpu_time/1000000) cpu,
        ROUND(elapsed_time/1000000) elapsed,
        executions, buffer_gets, disk_reads, rows_processed
   from stats$sql_summary) bb,
-- ---------------------------------------------------     end stats
(select snap_id,hash_value,
        ROUND(cpu_time/1000000) cpu,
        ROUND(elapsed_time/1000000) elapsed,
        executions, buffer_gets, disk_reads, rows_processed, module
   from stats$sql_summary) ee
-- ---------------------------------------------------     join subselects
 where ss.b_id=bb.snap_id
   and ss.e_id=ee.snap_id
   and bb.hash_value=ee.hash_value;

create index temporary_sql_all_idx
    on temporary_sql_all(hash_value)
       pctfree 0 storage(initial 1M next 256K);

exec   dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_ALL',CASCADE=>TRUE)

create table temporary_sql_all_by_hash pctfree 0 nologging
       storage(initial 128K next 128K) as
select hash_value,
       count(*)         hours,
       sum(executions)  executions,
       sum(buffer_gets) buffer_gets,
       sum(disk_reads)  disk_reads,
       sum(rows_processed) rows_processed,
       sum(cpu)            cpu,
       sum(elapsed)        elapsed
  from temporary_sql_all
 group by hash_value;

exec   dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_ALL_BY_HASH')

