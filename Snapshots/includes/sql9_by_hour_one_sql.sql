--           h:\sql\u\sql_by_hour_one_sql.txt

-- input parameters: hash_value of SQL to report
--                   SQL rank in category

-- called by h:\sql\u\sql_by_hour.txt

define one_hash_value = &1
clear computes breaks

set pagesize 0
select '                                                                ',
       '                                                                ',
       '================================================================',
       '                            SQL &one_hash_value                 ',
       '================================================================'
  from dual;
set pagesize 60

/*--------------------------------------------------------*/
/*     LIST THE SQL TEXT                                  */
/*--------------------------------------------------------*/
select sql_text,
       DECODE(instr(UPPER(sql_text),' FROM' ),0,
       DECODE(instr(UPPER(sql_text),' WHERE'),0,
       ' ','where'), 'from') " "
  from stats$sqltext
 where hash_value=&one_hash_value
 order by hash_value, piece;

/*--------------------------------------------------------*/
/*     FIRST LOAD TIME AND MODULE                         */
/*--------------------------------------------------------*/
set pagesize 0

select ' ' from dual;

select 'FIRST TIME = '||SUBSTR(first_load_time,1,10)||' '||
                        SUBSTR(first_load_time,12,5)
  from v$sqlarea
 where hash_value=&one_hash_value;

select 'MODULE     = '||SUBSTR(max(module),1,40)
  from temporary_sql_all
 where hash_value=&one_hash_value;

/*--------------------------------------------------------*/
/*     EXECUTION PLAN                                     */
/*--------------------------------------------------------*/
set    pagesize 60
col    operation   format a20 head 'EXECUTION PLAN'
col    options     format a14
col    object_name format a20
col    io_cost     format 9999990
col    cardinality format 9999990 head ROWS
col    id          noprint

select DISTINCT operation, options, object_name, cost, io_cost, cardinality, id
  from sys.v_$sql_plan
 where hash_value=&one_hash_value
 order by id;

/*--------------------------------------------------------*/
/*     TABLES                                             */
/*--------------------------------------------------------*/
col table_name    format a18
col avg_row_len   format 99990  head AVGLEN
col last_analyzed format a14
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
         from sys.v_$sql_plan 
        where hash_value=&one_hash_value
          and object_name IS NOT NULL) v
 where v.object_name=t.table_name
   and t.owner NOT IN ('SYS','SYSTEM');

/*--------------------------------------------------------*/
/*     INDEXES                                            */
/*--------------------------------------------------------*/
break on table_name on index_name on uniq on mb

col    pos format 90
select DISTINCT i.table_name, i.index_name, 
       DECODE(i.uniqueness,'UNIQUE','UNIQ',' ') UNIQ,
       ROUND(i.leaf_blocks*8/1024) MB,
       ic.column_position POS,
       tc.column_name, tc.num_distinct, tc.num_nulls 
 from (SELECT DISTINCT object_name
         from sys.v_$sql_plan 
        where hash_value=&one_hash_value
          and object_name IS NOT NULL) v,
       all_indexes      i,
       all_ind_columns  ic,
       all_tab_columns  tc
 where v.object_name=i.table_name
   and i.index_name=ic.index_name
   and i.table_name=tc.table_name
   and ic.column_name=tc.column_name
   and i.owner NOT IN ('SYS','SYSTEM')
 order by i.table_name, i.index_name, ic.column_position;

/*--------------------------------------------------------*/
/*     HOURLY DIFFERENCE DETAILS                          */
/*--------------------------------------------------------*/
clear breaks
break on report
compute sum of mins        on report
compute sum of cpu         on report
compute sum of elapsed     on report
compute sum of executions  on report
compute sum of buffer_gets on report
compute sum of disk_reads  on report
compute sum of processed   on report
col processed format 99999999

select  to_char(begin_time,'MM/DD HH24') Starting,
        (end_time-begin_time)*1440          mins,
        cpu, elapsed, executions, buffer_gets, disk_reads,
        rows_processed processed, substr(module,1,17) module
  from  temporary_sql_all
 where  hash_value=&one_hash_value
 order  by 1;


