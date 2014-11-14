set pagesize 500

spool h:\temp\x.sql

select 'spool c:\temp\x.out'
  from dual
/

select 'SELECT * FROM '||object_name||' WHERE rownum < 2;'
from user_objects
where object_type = 'SYNONYM'
/

spool off

@h:\temp\x.sql