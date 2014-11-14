/* h:\sql\u\tblsp.sql */

set    verify off
set    feedback off
set    linesize 110
col    tablespace_name format a24  head TABLESPACE
col    version         format a9
col    segment_type    format a20
col    segs            format 99990
col    mb              format 999990
col    max_mb          format 99990
col    freemb          format 999,990
col    extents         format 9999,990
col    filename        format a60
col    contents        format a9
col    version         format a10
col    host_name       format a20

/*--------------------------------------------------------*/
/*            TABLESPACE SIZE and MANAGEMENT              */
/*--------------------------------------------------------*/
select a.name database, UPPER('&1') Tablespace_name, c.tblsp_mb, 
       b.extent_management, b.allocation_type, b.contents 
  from v$database       a,
       user_tablespaces b,
      (select ROUND(sum(bytes)/1024/1024) tblsp_mb
         from dba_data_files where tablespace_name=UPPER('&1')) c
--      (select DECODE(substr(banner,1,19),'Oracle8i Enterprise','Oracle8i',
--                                         'Oracle9i Enterprise','Oracle9i',
--                                         'Oracle Database 10g','Oracle10g',
--                     substr(banner,1,9)) version
--         from v$version where rownum=1) d
       where b.tablespace_name=UPPER('&1');

select version, host_name from v$instance;

/*--------------------------------------------------------*/
/*            TABLESPACE SEGMENT SUMMARY                  */
/*--------------------------------------------------------*/
break  on report
compute sum of segs    on report
compute sum of mb      on report
compute sum of max_mb  on report
compute sum of extents on report

select DECODE(substr(segment_name,1,4),'BIN$','RECYCLEBIN',segment_type) segment_type,
       count(*) segs,
       round(sum(bytes)/1024/1024) MB, sum(extents) extents
  from dba_segments
 where tablespace_name = UPPER('&1')
 group by DECODE(substr(segment_name,1,4),'BIN$','RECYCLEBIN',segment_type);

/*--------------------------------------------------------*/
/*            TABLESPACE DATA FILES                       */
/*--------------------------------------------------------*/
select b.creation_time created, substr(a.file_name,1,60) FILENAME,
       ROUND(a.bytes/1024/1024) MB, a.status, a.autoextensible auto,
       ROUND(DECODE(a.autoextensible,'NO',a.bytes,a.maxbytes)/1024/1024) MAX_MB 
  from dba_data_files a, sys.v_$datafile_header b
 where a.tablespace_name=UPPER('&1')
   and a.file_id=b.file#
union
select b.creation_time created, substr(a.file_name,1,60) FILENAME,
       ROUND(a.bytes/1024/1024) MB, a.status, a.autoextensible auto,
       ROUND(DECODE(a.autoextensible,'NO',a.bytes,a.maxbytes)/1024/1024) MAX_MB 
  from dba_temp_files a, v$tempfile b
 where a.tablespace_name=UPPER('&1')
   and a.file_id=b.file#
  order by created;

select ROUND(sum(bytes)/1024/1024) FREEMB,
       ROUND(sum(trunc(bytes/1024/1024))) MB1,
       ROUND(sum(trunc(bytes/2/1024/1024)*2)) MB2,
       ROUND(sum(trunc(bytes/4/1024/1024)*4)) MB4,
       ROUND(sum(trunc(bytes/8/1024/1024)*8)) MB8,
       ROUND(sum(trunc(bytes/16/1024/1024)*16)) MB16,
       ROUND(max(bytes)/1024/1024) MAXMB
  from dba_free_space
 where tablespace_name=UPPER('&1');

clear breaks computes

/*--------------------------------------------------------*/
/*                 TOP 10 TABLES                          */
/*--------------------------------------------------------*/
col table_name format a31
col index_name format a31
col blkmb      format 99990
col leafmb     format 99990
col empty      format  9990
col num_rows   format 999999990
col 'INIT'     format a7 JUSTIFY RIGHT
col 'NEXT'     format a7 JUSTIFY RIGHT
col incr       format a5    JUSTIFY RIGHT
col exts       format 99990
col cmpr       format 990
/*
select * from
(select round(b.bytes/1024/1024) MB,
        round(      a.blocks*8/1024) BLKMB,
        round(a.empty_blocks*8/1024) EMPTY,
        RTRIM(a.owner)||'.'||a.table_name table_name,
        num_rows,
        DECODE(TRUNC(a.initial_extent/20000000),
          0,to_char(a.initial_extent/1024     ,'99990')||'K',
            to_char(a.initial_extent/1024/1024,'99990')||'M') "INIT",
        DECODE(TRUNC(a.next_extent/20000000),
          0,to_char(a.next_extent/1024     ,'99990')||'K',
            to_char(a.next_extent/1024/1024,'99990')||'M') "NEXT",
        to_char(a.pct_increase,'990')||'%' INCR,
        b.extents                    EXTS,
        last_analyzed
  from all_tables a, dba_segments b
 where a.tablespace_name=UPPER('&1')
   and b.segment_type='TABLE'
   and a.owner=b.owner
   and a.table_name=b.segment_name
 order by bytes DESC)
 where rownum<=10;
*/
select * from
(select round(b.bytes/1024/1024) MB,
        round(      a.blocks*8/1024) BLKMB,
        round(a.empty_blocks*8/1024) EMPTY,
        RTRIM(a.owner)||'.'||a.table_name||
             DECODE(b.segment_type,'TABLE','','('||to_char(b.prtns)||')') table_name,
        num_rows,
        DECODE(TRUNC(b.init_ext/20000000),
          0,to_char(b.init_ext/1024     ,'99990')||'K',
            to_char(b.init_ext/1024/1024,'99990')||'M') "INIT",
        DECODE(TRUNC(b.next_ext/20000000),
          0,to_char(b.next_ext/1024     ,'99990')||'K',
            to_char(b.next_ext/1024/1024,'99990')||'M') "NEXT",
        to_char(b.pct_increase,'990')||'%' INCR,
        b.extents                    EXTS,
        last_analyzed
  from all_tables a, 
      (select owner, segment_name, segment_type,
              sum(bytes) bytes, sum(extents) extents,
              max(initial_extent) init_ext,
              max(next_extent)    next_ext,
              max(pct_increase)   pct_increase, count(*) prtns
         from dba_segments 
        where segment_type LIKE 'TABLE%'
          and tablespace_name=UPPER('&1')
        group by owner, segment_name, segment_type) b
 where a.owner=b.owner
   and a.table_name=b.segment_name
  order by bytes DESC)
 where rownum<=10;

/*--------------------------------------------------------*/
/*                 TOP 10 INDEXES                         */
/*--------------------------------------------------------*/
select * from
(select round(b.bytes/1024/1024) MB,
        round(      a.leaf_blocks*8/1024) LEAFMB,
        RTRIM(a.owner)||'.'||a.index_name||
             DECODE(b.segment_type,'INDEX','','('||to_char(b.prtns)||')') index_name,
        num_rows,
        DECODE(TRUNC(b.init_ext/20000000),
          0,to_char(b.init_ext/1024     ,'99990')||'K',
            to_char(b.init_ext/1024/1024,'99990')||'M') "INIT",
        DECODE(TRUNC(b.next_ext/20000000),
          0,to_char(b.next_ext/1024     ,'99990')||'K',
            to_char(b.next_ext/1024/1024,'99990')||'M') "NEXT",
        to_char(b.pct_increase,'990')||'%' INCR,
        b.extents                    EXTS,
        last_analyzed,
        a.prefix_length cmpr
  from all_indexes a, 
      (select owner, segment_name, segment_type,
              sum(bytes) bytes, sum(extents) extents,
              max(initial_extent) init_ext,
              max(next_extent)    next_ext,
              max(pct_increase)   pct_increase, count(*) prtns
         from dba_segments
        where segment_type LIKE 'INDEX%'
          and tablespace_name=UPPER('&1')
        group by owner, segment_name, segment_type) b
 where a.owner=b.owner
   and a.index_name=b.segment_name
 order by bytes DESC)
 where rownum<=10;

set verify on
set feedback 6

