-- h(machose):\sql\u\tbs.sql
-- Reports on CL2PRA tablespaces
-- Bill MacHose

ttitle off
set pagesize 60
set linesize 105
set feedback off
col user  format a12
col graph format a20
col host_name format a20
col version format a10
col 'Time of Report' format a16

Select user, name "Database", 
       to_char(sysdate,'YYYY-MM-DD HH24:MI') "Time of Report", host_name, version
  from v$database, v$instance;

-- select banner "Oracle Version" from v$version where rownum=1;


-- *******************************************************
--                   Space by Tablespace
-- *******************************************************
col tablespace_name format a22
col TotlMB   format 9,999,990
col FreeMB   format  999,990
col MxFree   format  99,990
col 'Used'   format a5   justify right
col Action   format a7
col unifrm   format a6
col  mgmt    format a5
col contents  format a1
col data_file format a1
--break on report
--compute sum of 'FreeMB' on report
--compute sum of 'TotlMB' on report

select tablespace_name,
       sum( allbytes)/1024/1024 "TotlMB",
       DECODE(max(data_file),'D',sum(freebytes)/1024/1024,NULL) "FreeMB",
       DECODE(max(data_file),'D',max(maxbytes) /1024/1024,NULL) "MxFree",
       DECODE(max(data_file),'D',
              TO_CHAR((sum(allbytes)-sum(freebytes))/sum(allbytes)*100,'990')||'%',NULL) "Used",
       DECODE(max(data_file),'D',
          DECODE(TRUNC((sum(allbytes)-sum(freebytes))/sum(allbytes)*10),
              '9','Danger',
              '8','Warning',' '),NULL) "Action",
       DECODE(max(data_file),'D',SUBSTR('==========******WWDD',1,
         CEIL((sum(allbytes)-sum(freebytes))/sum(allbytes)*20)),NULL) Graph,
       DECODE(max(mgmt),'DICTIONARY',' ',max(mgmt)) Mgmt, max(uniform) unifrm,
       substr(max(contents),1,1) contents,
       DECODE(max(data_file),'D','D','T') data_file
  from (select tablespace_name,0 allbytes, sum(bytes) freebytes,
               max(bytes) maxbytes, ' ' mgmt, ' ' uniform, ' ' contents,
               ' ' data_file 
          from dba_free_space group by tablespace_name
               UNION
        select tablespace_name,sum(bytes) allbytes, 0 freebytes,
               0 maxbytes, ' ' mgmt, ' ' uniform, ' ' contents, 'D' data_file
          from dba_data_files group by tablespace_name
               UNION
        select tablespace_name,sum(bytes_used+bytes_free) allbytes,
               sum(bytes_free) freebytes, sum(bytes_free) maxbytes,
              ' ' mgmt, ' ' uniform, ' ' contents, 'T' data_file
          from v$temp_space_header group by tablespace_name
               UNION
        select tablespace_name, 1 allbytes, 1 freebytes, 0 maxbytes,
               extent_management mgmt,
               decode(allocation_type,'UNIFORM',
               decode(TRUNC(next_extent/1024/1024),0,
                      LPAD(to_char(next_extent/1024)     ,5)||'K',
                      LPAD(to_char(next_extent/1024/1024),5)||'M'),' ')
                      uniform,
               contents, ' ' data_file
          from dba_tablespaces)
  group by tablespace_name
  order by tablespace_name;

set pagesize 0
select '---------------------- ---------- -------- ------ -----' from dual;

col freemb format 9999990
col mxfree format  999990
select 'TOTAL' tablespace_name, totlmb+temp_totl totlmb, freemb+temp_free freemb,
       GREATEST(mxfree,temp_free) mxfree,
       to_char((totlmb-freemb+temp_totl-temp_free)/
                GREATEST(1,totlmb+temp_totl)*100,'999')||'%' USED
  from (select ROUND(sum(bytes)/1024/1024) FREEMB,
               ROUND(max(bytes)/1024/1024) MXFREE from user_free_space) a,
       (select ROUND(sum(bytes)/1024/1024) TOTLMB from dba_data_files ) b,
       (select ROUND((sum(bytes_used)+sum(bytes_free))/1024/1024) TEMP_TOTL,
               ROUND(sum(bytes_free)/1024/1024) TEMP_FREE
               from v$temp_space_header) c;

set pagesize 60
set feedback 6

--select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') TIMECHECK from dual;


/*-------------------------------------------------------------------*/
/* Report when largest free space is less than 10% of all free space */
/*         and largest free space less than 5 times largest extent   */
/*         and largest free space less than 100 MB                   */
/*         and tablespace is NOT locally managed with uniform extents*/
/*-------------------------------------------------------------------*/
col 'very fragmented'  format a15
col         mb  format 99990
col     freemb  format 99990
col  maxfreemb  format a9
col  maxnextmb  format 99990
select a.tablespace_name "VERY FRAGMENTED",
       ROUND(       bytes/1024/1024)        MB,
       ROUND(   freebytes/1024/1024)    FREEMB,
       LPAD(TO_CHAR(ROUND(maxfreebytes/1024/1024)),5)||
       '('||TO_CHAR(ROUND(maxfreebytes/bytes*100))||'%)' MAXFREEMB,
       ROUND(maxnextbytes/1024/1024) MAXNEXTMB
  from (select tablespace_name,sum(bytes) bytes
          from dba_data_files
         group by tablespace_name) a,
       (select tablespace_name,sum(bytes) freebytes,
               max(bytes) maxfreebytes
          from dba_free_space
         group by tablespace_name) b,
        user_tablespaces           c,
       (select tablespace_name,max(next_extent) maxnextbytes
          from dba_segments
         where segment_type<>'SPACE HEADER'
         group by tablespace_name) d
 where a.tablespace_name=b.tablespace_name
   and a.tablespace_name=c.tablespace_name
   and a.tablespace_name=d.tablespace_name
   and c.allocation_type <> 'UNIFORM'
   and c.tablespace_name <> 'RBS'
   and b.maxfreebytes/bytes<.1
   and b.maxfreebytes<5*d.maxnextbytes
   and b.maxfreebytes<100*1024*1024;

