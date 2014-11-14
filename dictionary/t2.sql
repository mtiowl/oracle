--  created by Bill MacHose  Nov 2000  to get table statistics
--
--  To execute:  @t <schema> <table>
--
set pagesize 60
set linesize 100
set sqlcase upper
set verify off
set feedback 20
set autotrace off

define blksize=8192

host clear;

/*-----------------------------------------------------------------*/
/*                   TABLE STATISTICS                              */
/*-----------------------------------------------------------------*/
column tablespace_name format a11
column tablespace      format a11
column rows         format  9,999,999,990
column sample_size  format  9,999,999,990
column row_len      format         999990
column init_KB      format      9,999,990
column next_KB      format        999,990
column max_extents  format  9,999,999,990
column bytes        format 99,999,999,990
column ext_kb       format      9,999,990
column extents      format      9,999,990
column blocks       format     99,999,990
column KB           format    999,999,990
column MB           format        999,999.9
column 'empty KB'   format        999,990
column 'row len'    format        999,990
column analyzed     format            a15
column histogram_col_name format      a24
column 'NOT NULL'   format            a8
--
select table_name,
       num_rows     "ROWS",
       avg_row_len  "ROW_LEN",
       chain_cnt    "CHAINED",
       tablespace_name "TABLESPACE"
       from ALL_tables where owner='&1' and table_name='&2';
--
select created,
       last_ddl_time "LAST DDL",
       to_char(last_analyzed,'DD-MON-YY HH24:MI') "ANALYZED",
       sample_size, partitioned 
--, compression  (doesn't work for Oracle8i)
       from ALL_objects a, ALL_tables b
       where a.owner='&1'
         and b.owner='&1'
         and object_name='&2'
         and object_type='TABLE'
         and table_name='&2';
--
select initial_extent/1024 "INIT_KB",
       next_extent/1024    "NEXT_KB",
       max_extents,
       pct_increase   "PCT_INCR",
       pct_used,
       pct_free, avg_space
       from ALL_tables
 where owner='&1' and table_name='&2';
--
break on report
compute sum of extents on report
compute sum of blocks  on report
compute sum of kb      on report
compute sum of mb      on report
--
select bytes/1024          "EXT_KB",
       N                   "EXTENTS",
       bytes*N/1024 "KB",
       bytes*N/1024/1024 "MB",
       bytes*N/to_number(value) "BLOCKS"
  from (select bytes, count(*) N from user_extents
         --where owner='&1' 
           where segment_name='&2'
           and segment_type LIKE 'T%'
         group by bytes) a,
        v$parameter b
 where UPPER(b.name)='DB_BLOCK_SIZE'
       order by 1 DESC;
 
set head off
clear breaks
column CALC  format a20
column HEAD1 format a21
select 'DATA BLOCKS        ' HEAD1,
       blocks*to_number(b.value)/1024      "KB",
       blocks*to_number(b.value)/1024/1024 "MB",
       blocks,
       DECODE(avg_row_len,0,' ',
       '  (Calc: '||to_char(ROUND(CEIL(num_rows/
         DECODE(TRUNC((to_number(b.value)-100)*(1-NVL(PCT_FREE,5)/100)/avg_row_len),0,
                      (to_number(b.value)-100)*(1-NVL(PCT_FREE,5)/100)/avg_row_len ,
                TRUNC((to_number(b.value)-100)*(1-NVL(PCT_FREE,5)/100)/avg_row_len))
         )*to_number(b.value)/1024/1024))||' MB)') "CALC"
       from ALL_tables a, v$parameter b
       where owner='&1' and table_name='&2'
         and UPPER(b.name)='DB_BLOCK_SIZE';
 
select 'EMPTY BLOCKS       ' HEAD1,
       empty_blocks*to_number(b.value)/1024    "KB",
       empty_blocks*to_number(b.value)/1024/1024 "MB",
       empty_blocks      "BLOCKS"
  from ALL_tables a, v$parameter b
       where owner='&1' and table_name='&2'
         and UPPER(b.name)='DB_BLOCK_SIZE';
 
/*-----------------------------------------------------------------*/
/*                   INDEXES                                       */
/*-----------------------------------------------------------------*/
set head on
column Key1       format a16
column index_name format a30
column Exts format 9999
column prtns   format 990
column leaf_mb format 99990
column index_type format a10
select a.index_name, sum(b.bytes)/1048576 "MB",
       ROUND(max(a.leaf_blocks)*to_number(p.value)/1024/1024) LEAF_MB, count(*) Prtns,
       sum(b.extents) extents, uniqueness, a.prefix_length "Cmprs",
       index_type
  from ALL_indexes a, ALL_segments b, v$parameter p
where a.owner='&1'
   and a.table_name='&2'
   and a.owner=b.owner
   and a.index_name=b.segment_name
   and b.segment_type LIKE 'I%'
   and UPPER(p.name)='DB_BLOCK_SIZE'
 group by a.index_name, uniqueness, a.prefix_length, index_type, to_number(p.value)
order by 1;
--
break  on index_name
col    column_name format a24
col    data_type   format a16
col    num_distinct format 99,999,990
select b.index_name,b.column_name,c.num_distinct,
       c.data_type||'('||to_char(data_length)||')' data_type
  from ALL_ind_columns b, ALL_tab_columns c
 where b.table_owner='&1'
   and b.table_owner=c.owner(+)
   and b.table_name='&2'
   and b.table_name=c.table_name(+)
   and b.column_name=c.column_name(+)
 order by index_name,column_position;

/*-----------------------------------------------------------------*/
/*                   COLUMNS                                       */
/*-----------------------------------------------------------------*/
col column_name  format a30
col num_distinct format 999999999 head 'DISTINCT'
col num_nulls    format 99999999  head 'NULLS'
col owner format a12
col avg_col_len format 990 head 'COL|LEN'
col data_type format a8 head 'DATATYPE'
col 'ORDER' format 9990
col buckets format 999990 head 'HISTOGRAM|BUCKETS'
col max_bucket format 999990 head 'MAX|BUCKET'

select a.column_name "TABLE COLUMNS",num_distinct,num_nulls,substr(data_type,1,8) data_type,
       avg_col_len,decode(NULLABLE,'N','NOT NULL',' ') "NOT NULL", column_id "ORDER",
       b.buckets, b.max_bucket 
  from all_tab_columns a, 
      (select owner,table_name,column_name,count(*) buckets, max(endpoint_number) max_bucket
         from ALL_histograms
        where owner='&1' and table_name ='&2' and endpoint_number>1
        group by owner,table_name,column_name) b
 where a.owner='&1' and a.table_name='&2'
   and a.owner=b.owner(+) and a.table_name=b.table_name(+) and a.column_name=b.column_name(+)
 order by a.column_name;

set feedback off

/*-----------------------------------------------------------------*/
/*                   LOB COLUMNS                                   */
/*-----------------------------------------------------------------*/
select a.column_name,b.segment_type,b.tablespace_name,ROUND(b.bytes/1024/1024) MB
from all_lobs a, ALL_segments b
where a.owner=UPPER('&1')
  and a.table_name=UPPER('&2')
  and a.owner=b.owner
  and a.segment_name=b.segment_name
order by 1;

/*-----------------------------------------------------------------*/
/*                   TRIGGERS                                      */
/*-----------------------------------------------------------------*/
select trigger_name, status
  from ALL_triggers
 where table_owner='&1'
   and table_name ='&2';

/*-----------------------------------------------------------------*/
/*                   TABLE PRIVILEGES                              */
/*-----------------------------------------------------------------*/
select 'GRANT ' || PRIVILEGE || ' TO ' ||GRANTEE  "TABLE GRANTS"
  from all_tab_privs
 where table_schema='&1' and table_name='&2'
 order by grantee, privilege;

set pagesize 60
col version format a12
col host_name format a12
select UPPER('&1..&2  ') "TABLE" ,a.name database, b.version, b.host_name, to_char(sysdate,'HH24:MI:SS') ts
  from v$database a, v$instance b;

set feedback 10
set sqlcase mixed
set verify on
clear breaks
clear computes
