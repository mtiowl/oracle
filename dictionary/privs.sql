set verify off
set feedback 20
set pagesize 50
set linesize 120
col version           format a10
col host_name         format a20
col username          format a8
col account_status    format a16
col default_tblsp     format a13
col temp_tblsp        format a10
col profile           format a12
col granted_role      format a21
col grantee           format a21
col 'TABLE PRIVILEGE' format a20
col 'SYSTEM PRIVILEGE' format a27
col revoke_sql        format a50

select to_char(sysdate,'YYYY-MM-DD HH24:MI') ts, name, version, host_name
  from v$database, v$instance;

select username,account_status,created, default_tablespace default_tblsp,
       temporary_tablespace temp_tblsp, profile
  from dba_users where username=UPPER('&1');

select object_type,count(*),ROUND(SUM(s.bytes)/1024/1024) MB
  from all_objects o, dba_segments s
 where o.owner=UPPER('&1')
   and o.owner=s.owner(+)
   and o.object_name=s.segment_name(+)
 group by object_type
 order by 1;

select granted_role,
      'REVOKE '||granted_role||UPPER(' FROM &1;') REVOKE_SQL
 from dba_role_privs where grantee=UPPER('&1')
 order by 1;

select grantee,privilege "SYSTEM PRIVILEGE",
       DECODE(grantee,UPPER('&1'),'REVOKE '||privilege||UPPER(' FROM &1;'),
                           ' ') REVOKE_SQL
  from dba_sys_privs
 where grantee=UPPER('&1')
    or grantee in (
       select granted_role from dba_role_privs
        where grantee=UPPER('&1'))
 order by 1,2;

select grantee "User/Role",count(*) "Number of Table Privileges" from dba_tab_privs
 where grantee=UPPER('&1')
    or grantee IN (select granted_role from dba_role_privs where grantee=UPPER('&1'))
 group by DECODE(grantee,UPPER('&1'),1,2),grantee;
