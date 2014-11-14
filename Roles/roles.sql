Select a.grantee User_name, a.granted_role role, b.privilege
 from DBA_ROLE_PRIVS a, DBA_SYS_PRIVS b 
 where a.granted_role=b.grantee and a.grantee='&user_name'
/