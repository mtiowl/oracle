--  created by Bill MacHose  Nov 2000  to get table statistics
set pagesize 60
set sqlcase upper
set verify off
set feedback off
host clear;
--analyze index &1..&2 estimate statistics;
column index_name  format a20
column table_name  format a20
column tablespace_name format a15
column compress    format         9,990
column rows        format   999,999,990
column initial_k   format     9,999,990
column next_k      format       999,990
column max_extents format 9,999,999,990
column kb          format     9,999,990
column mb          format         99990
column ext_kb      format    9,999,990
column column_name format a30
column partitions  format 9990
column index_type  format a10
column last_analyzed format a16
--
select index_name,
       table_name,
       uniqueness,
       tablespace_name,
       partitioned,
       prefix_length "compress"
       from all_indexes
       where owner='&1' and index_name='&2';
--
select a.created,
       a.last_ddl_time,
       to_char(b.last_analyzed,'DD-MON-YY HH24:MI') "LAST_ANALYZED",
       a.status||' INDEX' STATUS, b.sample_size, b.partitioned,
       b.index_type
       from dba_objects a, dba_indexes b
       where a.owner='&1'
         and b.owner='&1'
         and a.object_name='&2' 
         and a.object_type='INDEX'
         and b.index_name='&2';
--
select initial_extent/1024 "INITIAL_K",
       next_extent/1024    "NEXT_K", 
       max_extents,
       pct_increase   "PCT_INCR",
       pct_free       "PCT_FREE",
       1              "PARTITIONS"
       from dba_indexes
       where owner='&1' and index_name='&2'
         and initial_extent IS NOT NULL
UNION
select initial_extent/1024 "INITIAL_K",
       next_extent/1024    "NEXT_K", 
       max_extent     "max_extents",
       pct_increase   "PCT_INCR",
       pct_free       "PCT_FREE",
       count(*)       "PARTITIONS"
       from dba_ind_partitions
       where index_owner='&1' and index_name='&2'
       group by initial_extent, next_extent, max_extent,
                pct_increase, pct_free
;
--
select num_rows "ROWS", leaf_blocks,ROUND(leaf_blocks*to_number(value)/1024/1024) LEAF_MB,
       ROUND(leaf_blocks*to_number(value)/GREATEST(1,num_rows),1) avg_entry_len
  from dba_indexes a, v$parameter b
 where owner='&1' and index_name='&2'
   and upper(name)='DB_BLOCK_SIZE';
--
break on report
compute sum of extents on report
compute sum of blocks  on report
compute sum of kb      on report
compute sum of mb      on report
--
select bytes/1024          "EXT_KB",
       count(*)            "EXTENTS",
       bytes*count(*)/1024 "KB",
       bytes*count(*)/1024/1024 "MB",
       bytes*count(*)/to_number(b.value) "BLOCKS"
       from dba_extents a, v$parameter b
       where owner='&1' and segment_name='&2'
         and segment_type LIKE 'I%'
         and UPPER(b.NAME)='DB_BLOCK_SIZE'
       group by bytes, to_number(b.value)
       order by 1 DESC;
--
compute sum of avg_col_len on report
col    avg_col_len format 99990
col    data_type   format a9
select a.column_name,
       b.data_type,
       b.avg_col_len,
       b.num_distinct "DISTINCT",
       ROUND(c.num_rows/decode(num_distinct,0,1,num_distinct)) "Rows/Key"
  from dba_ind_columns a,
      (select * from dba_tab_columns
        where owner='&1'
          and table_name IN (
              select table_name
                from dba_indexes
               where owner='&1'
                 and index_name='&2') ) b,
       dba_indexes c
 where a.index_owner='&1'
   and c.owner='&1'
   and a.index_name='&2'
   and c.index_name='&2'
   and a.column_name=b.column_name(+)
 order by a.column_position;

col version format a12
select UPPER('&1..&2  ') "INDEX" ,a.name database, b.version, b.host_name, to_char(sysdate,'HH24:MI:SS') ts
  from v$database a, v$instance b;
--
set sqlcase mixed
set feedback 6
set verify on
clear breaks
clear computes

