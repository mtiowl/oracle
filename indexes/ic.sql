
col owner      format a12
col index_name format a30
col mb         format 99,990
col rebld_mb   format 99,990  head 'REBLD|  MB'
col compr_mb   format 99,990  head 'COMPR|  MB'
col rsaved     format a5   head 'REBLD|SAVED'
col csaved     format a5   head 'COMPR|SAVED'
col num_rows   format 999,999,990
col COL1_DISTINCT head "DISTINCT"
col cols       format 990
col tablespace_name format a15
col prtns      format 9990
col cmpr       format 90

set pagesize 50
set linesize 200
break on report
compute sum of mb on report
compute sum of rebld_mb on report
compute sum of compr_mb on report

/*------------------------------------------------------*/
/*          Average Column Length >= size               */
/*------------------------------------------------------*/
Select owner, index_name, table_name, mb, rebld_mb, compr_mb,
       LPAD(TO_CHAR(ROUND(100*(1-REBLD_MB/GREATEST(1,      MB)))),4)||'%' RSAVED,
       LPAD(TO_CHAR(ROUND(100*(1-COMPR_MB/GREATEST(1,REBLD_MB)))),4)||'%' CSAVED,
       cols, tablespace_name, prtns, cmpr
  From (
select a.owner, a.index_name, a.table_name,
       ROUND(b.bytes/1024/1024) MB, 
       ROUND(a.num_rows*(b.COL1_len+b.other_col_len+10)/(1-NVL(pct_free,10)/100)/1024/1024*1.05) REBLD_MB,
       ROUND(a.num_rows*(b.other_col_len
               +COL1_len*b.COL1_distinct / GREATEST(a.num_rows,1) +1+10)
               /(1-NVL(pct_free,10)/100)/1024/1024*1.05) COMPR_MB,
       b.cols, a.tablespace_name, b.prtns, a.prefix_length cmpr
  from all_indexes a, 
      (select xx.index_owner, xx.index_name,
              SUM(DECODE(xx.column_position,1, 0,yy.avg_col_len)) other_col_len,
              SUM(DECODE(xx.column_position,1,yy.avg_col_len ,0)) COL1_len,
              SUM(DECODE(xx.column_position,1,yy.num_distinct,0)) COL1_distinct,
              COUNT(*) COLS, zz.bytes, zz.prtns
         from all_ind_columns xx,
              all_tab_columns yy,
             (select owner, segment_name, sum(bytes) bytes, count(bytes) prtns
                from dba_segments
                where segment_type   LIKE     'INDEX%'
                 and owner           NOT IN  ('SYS','SYSTEM','SYSMAN')
                 and tablespace_name NOT IN  ('SYSTEM','SYSAUX')
                 and segment_name    NOT LIKE 'BIN$%'
                 and (partition_name IS NOT NULL or bytes>40*1024*1024)
               group by owner, segment_name) zz
        where xx.table_owner = yy.owner
          and xx.table_name  = yy.table_name
          and xx.column_name = yy.column_name
          and xx.table_owner NOT IN ('SYS','SYSTEM','SYSMAN')
          and yy.owner       NOT IN ('SYS','SYSTEM','SYSMAN')
          and yy.avg_col_len IS NOT NULL
          and zz.owner       = xx.index_owner
          and zz.segment_name= xx.index_name
          and zz.bytes       > 20*1024*1024
        group by xx.index_owner, xx.index_name, zz.bytes, zz.prtns) b
 where a.last_analyzed >= sysdate-30
   and a.index_type   = 'NORMAL'
   and a.owner        = b.index_owner
   and a.index_name   = b.index_name )
 where (1-COMPR_MB/GREATEST(1,REBLD_MB) > .30
    or  1-REBLD_MB/GREATEST(1,      MB) > .60)
   and  1-COMPR_MB/GREATEST(1,      MB) > .30
 order by 3,1,2;


