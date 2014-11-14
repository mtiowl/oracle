set linesize 100
col version   format a12
col host_name format a22
col ts        format a8
col user      format a20
col cpus      format a4
col sid       format 9990
select a.name, b.version, b.host_name,
       to_char(sysdate,'HH24:MI:SS') ts, user, c.value cpus, sid
  from v$database a, v$instance b, v$parameter c, v$session d
 where c.name='cpu_count'
   and d.audsid=SYS_CONTEXT('USERENV','SESSIONID');
