spool H:\Oracle\DBA\dictionary\x.sql

select 'EXEC DBMS_DDL.alter_compile(''PACKAGE BODY'', user, '''||object_name||''')'
from user_objects
where object_type = 'PACKAGE BODY'
  and status = 'INVALID'
/

spool off