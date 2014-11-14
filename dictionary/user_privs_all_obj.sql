set serveroutput on size 1000000
set linesize 300
set verify off

ACCEPT l_user prompt 'Enter user: '


spool c:\temp\privs_obj.out

prompt *** System Privs **
prompt *******************
select grantee, privilege
  from dba_sys_privs
  where grantee = upper('&l_user');

prompt ** Granted Roles **
prompt *******************
select grantee, granted_role
  from dba_role_privs
  where grantee = upper('&l_user');

prompt ** Privs Granted via Roles **
prompt *******************  
select grantee, granted_role, table_name, privilege
  from dba_role_privs
      ,role_tab_privs
   where role = granted_role
     and grantee = upper('&l_user')
   order by table_name;

prompt *** Table Privs **
prompt *******************
select grantee, owner, table_name, privilege 
  from dba_tab_privs
  where grantee = upper('&l_user')
  order by table_name;

spool off
prompt ***** Output c:\temp\privs_obj.out
set linesize 100
set verify on