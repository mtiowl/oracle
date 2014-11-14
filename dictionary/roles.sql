set linesize 300
set verify off
column role format a40

Accept l_object_name prompt 'Enter Objec Name: '

-- To see what is gratned to your current user
SELECT * 
  FROM (select grantee username, null as role, table_name, privilege 
          from user_tab_privs 
          where table_name = upper('&l_object_name')
            and grantee = user
        UNION
        select username, granted_role, table_name, privilege
          from user_role_privs
              ,role_tab_privs
          where role = granted_role) x
  WHERE x.table_name = upper('&l_object_name')
/

--To See the grants given by the current user
select grantor, grantee, null as role, table_name, privilege 
          from user_tab_privs 
          WHERE grantor = user
            AND table_name = upper('&l_object_name')
/

set linesize 100
set verify on