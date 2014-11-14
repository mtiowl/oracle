set linesize 300
set verify off

ACCEPT l_user prompt 'Enter user: '

spool c:\temp\privs.out

prompt *** System Privs **
prompt *******************
select grantee, null, null, privilege
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
     and grantee = upper('&l_user');

prompt ** System Granted via Roles **
prompt *******************  
select grantee, granted_role, privilege
  from dba_role_privs
      ,role_sys_privs
   where role = granted_role
     and grantee = upper('&l_user');

prompt *** Table Privs **
prompt *******************
select grantee, owner, table_name, privilege 
  from dba_tab_privs
  where grantee = upper('&l_user');

spool off
prompt ***** Output c:\temp\privs.out
set linesize 100
set verify on