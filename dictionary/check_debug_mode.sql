select owner, count(*), max(last_ddl_time) 
from sys.all_probe_objects
where debuginfo = 'T'
group by owner
/
