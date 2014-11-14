col    account_status format a15
col    mb_used        format 999990
col    mb_quota       format a9
set linesize 90
set pagesize 40
set verify off

select a.username, a.account_status, a.created,
       to_char(a.lock_date,'YYYY-MM-DD HH24:MI') locked, b.name database
  from dba_users a, v$database b
 where username=UPPER('&1');

select default_tablespace, temporary_tablespace from dba_users
 where username=UPPER('&1');

select tablespace_name,ROUND(bytes/1024/1024) MB_USED,
       DECODE(max_bytes,-1,'UNLIMITED',
          LPAD(TO_CHAR(ROUND(max_bytes/1024/1024)),8)) MB_QUOTA
  from dba_ts_quotas 
 where username=UPPER('&1')
 order by tablespace_name;
