-- h:\sql\u\sql10_by_hour_all_sqls.sql

create table temporary_sql_all pctfree 0 nologging
       storage(initial 1m next 256K) as
select a.sql_id,
       p.plan_hash_value,          
       b.begin_interval_time      begin_time,
       b.end_interval_time        end_time,
       executions_delta           executions,
       buffer_gets_delta          buffer_gets,
       disk_reads_delta           disk_reads,
       rows_processed_delta       rows_processed,
       cpu_time_delta/1000000     cpu,
       elapsed_time_delta/1000000 elapsed,
       nvl(p.cost,0)              cost,
       module
    from sys.dba_hist_sqlstat  a,
         sys.wrm$_snapshot     b,
         DBA_HIST_SQL_PLAN     p
 where a.snap_id=b.snap_id
   and a.sql_id = p.sql_id
   and a.PLAN_HASH_VALUE = p.PLAN_HASH_VALUE
   and p.id = 0
   and a.snap_id between &first_snap and &last_snap;

create index temporary_sql_all_idx
    on temporary_sql_all(sql_id)
       pctfree 0 storage(initial 1M next 256K);

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_ALL',CASCADE=>TRUE)

create table temporary_sql_all_by_sqlid pctfree 0 nologging
       storage(initial 128K next 128K) as
select sql_id, plan_hash_value, substr(module,1, 25) module,
       count(*) hours,
       sum(executions) executions,
       sum(buffer_gets) buffer_gets,
       sum(disk_reads)  disk_reads,
       sum(rows_processed) rows_processed,
       sum(cpu)            cpu,
       sum(elapsed)        elapsed,
       cost                cost
  from temporary_sql_all
 group by sql_id, plan_hash_value, substr(module,1,25), cost;

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_ALL_BY_SQLID')

create table temporary_sql_plans_by_sqlid pctfree 0 nologging
       storage (initial 128K next 128k)
  AS SELECT sql_id, plan_hash_value
           ,id
           ,LPAD(' ',depth)||OPERATION||'_'||OPTIONS operation
           ,OBJECT_NAME  
           ,temp_space
           ,bytes
           ,cpu_cost
           ,io_cost
           ,cost
      FROM DBA_HIST_SQL_PLAN
      order by  ID,PLAN_HASH_VALUE;

exec dbms_stats.gather_table_stats(USER,'TEMPORARY_SQL_PLANS_BY_SQLID')