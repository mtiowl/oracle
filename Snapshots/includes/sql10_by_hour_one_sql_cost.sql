-- h:\sql\u\sql10_by_hour_one_sql.txt

-- input parameters: sql_id of SQL to report
--                   SQL rank in category

-- called by h:\sql\u\sql10_by_hour.sql

define one_sql_id = &1
define one_sql_hash = &2
clear computes breaks

set pagesize 0
select '                                                                ',
       '                                                                ',
       '================================================================',
       '                            SQL &one_sql_id                 ',
       '             hash: &one_sql_hash                            ',
       '================================================================'
  from dual;
set pagesize 60

/*--------------------------------------------------------*/
/*     LIST THE SQL TEXT                                  */
/*--------------------------------------------------------*/
set long 4000
col sql_text format a80
select sql_text
  from dba_hist_sqltext
 where sql_id='&one_sql_id';

/*--------------------------------------------------------*/
/*     FIRST LOAD TIME AND MODULE                         */
/*--------------------------------------------------------*/
set pagesize 0

select ' ' from dual;

--select 'FIRST TIME = '||SUBSTR(first_load_time,1,10)||' '||
--                        SUBSTR(first_load_time,12,5)
--  from v$sqlarea
-- where sql_id=&one_sql_id;

--select 'MODULE     = '||SUBSTR(max(module),1,40)
--  from temporary_sql_all
-- where sql_id='&one_sql_id';

/*--------------------------------------------------------*/
/*     EXECUTION PLAN                                     */
/*--------------------------------------------------------*/
set    pagesize 60
col    timestamp   format a10
col    begin_snap  format a16
col      end_snap  format a16
col    status      format a6
col    operation   format a20 head 'EXECUTION PLAN'
col    options     format a14
col    object_name format a20
col    io_cost     format 9999990
col    cardinality format 9999990 head ROWS
col    id          noprint
col    'ORDER'     format 9990

select to_char(a.timestamp,'YYYY-MM-DD') timestamp,
       a.plan_hash_value,  a.cost,
       to_char(c.begin_interval_time,'YYYY-MM-DD-HH24:MI') begin_snap,
       to_char(d.begin_interval_time,'YYYY-MM-DD-HH24:MI')   end_snap,
       DECODE(CEIL(sysdate-
       to_date(to_char(d.begin_interval_time,'YYYY-MM-DD'),'YYYY-MM-DD')),
              1,'RECENT',NULL,'?','OLD') status
  from (select sql_id, plan_hash_value,
               max(timestamp) timestamp, max(cost) cost 
          from sys.dba_hist_sql_plan
         where sql_id='&one_sql_id'
           and plan_hash_value = '&one_sql_hash'
         group by sql_id, plan_hash_value) a,
       (select sql_id, plan_hash_value,
               min(snap_id) min_snap, max(snap_id) max_snap
          from sys.dba_hist_sqlstat
         where sql_id='&one_sql_id'
           and plan_hash_value = '&one_sql_hash'
         group by sql_id, plan_hash_value) b,
       sys.wrm$_snapshot                   c,
       sys.wrm$_snapshot                   d
 where a.plan_hash_value=b.plan_hash_value(+)
   and b.min_snap=c.snap_id(+)
   and b.max_snap=d.snap_id(+)
 order by 1;

break  on plan_hash skip 1

select DISTINCT a.plan_hash_value plan_hash,operation, options, object_name,
                cost, cardinality, max_depth-depth+1 "ORDER", id
  from sys.dba_hist_sql_plan a,
      (select plan_hash_value, max(depth) max_depth
         from dba_hist_sql_plan 
         where sql_id='&one_sql_id'
           and plan_hash_value = '&one_sql_hash'
        group by plan_hash_value) b
 where sql_id='&one_sql_id'
   and a.plan_hash_value = '&one_sql_hash'
   and a.plan_hash_value=b.plan_hash_value
 order by a.plan_hash_value,id;

/*--------------------------------------------------------*/
/*     TABLES                                             */
/*--------------------------------------------------------*/
col table_name    format a18
col avg_row_len   format 99990  head AVGLEN
col last_analyzed format a14
col sample        format a6
col pctf          format 990
col pctu          format 990
col index_name    format a20
col uniq          format a4
col column_name   format a18
col mb            format 999990
col used_mb       format 999990
col calc_mb       format 999990
col num_distinct  format 999990 head 'DISTINCT'
col num_nulls     format 999990 head 'NULLS'

clear breaks

select t.table_name, t.num_rows, t.avg_row_len, 
       TO_CHAR(last_analyzed,'MM/DD/YY HH24:MI') last_analyzed,
       TO_CHAR(ROUND(t.sample_size*100/GREATEST(num_rows,1)),'990')||'%' SAMPLE,
       ROUND((blocks+empty_blocks)*8/1024) MB,
       ROUND(blocks*8/1024) USED_MB,
       ROUND(t.num_rows*t.avg_row_len/1024/1024/(1-pct_free/100)) CALC_MB,
       pct_free pctf, pct_used pctu
  from all_tables t,
      (SELECT DISTINCT object_name
         from sys.dba_hist_sql_plan 
        where sql_id='&one_sql_id'
          and object_name IS NOT NULL) v
 where v.object_name=t.table_name
   and t.owner NOT IN ('SYS','SYSTEM');

/*--------------------------------------------------------*/
/*     INDEXES                                            */
/*--------------------------------------------------------*/
break on table_name on index_name on uniq on mb
/*     Index list turned off because it was taking too long */
/*     see sql10_by_hour_indexes.sql                        */

/*--------------------------------------------------------*/
/*     HOURLY DIFFERENCE DETAILS                          */
/*--------------------------------------------------------*/
clear breaks
break on report
--compute sum of mins        on report
compute sum of cpu         on report
compute sum of elapsed     on report
compute sum of executions  on report
compute sum of buffer_gets on report
compute sum of disk_reads  on report
compute sum of processed   on report
col starting  format a8
col processed format 99999999

select  to_char(begin_time,'MM/DD HH24') Starting,
--        (end_time-begin_time)*1440          mins,
        cpu, elapsed, executions, buffer_gets, disk_reads,
        rows_processed processed
-- , substr(module,1,17) module
  from  temporary_sql_all
 where  sql_id='&one_sql_id'
 order  by 1;


