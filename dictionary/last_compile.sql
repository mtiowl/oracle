select object_type, created, last_ddl_time
from all_objects
where object_name = '&object_name'
/
