set linesize 300
col object_name format a40

select owner, object_name, object_type, status, last_ddl_time
  from all_objects
  where status = 'INVALID'
and owner NOT IN ('PPLQUEST', 'SYSTEM', 'PUBLIC', 'SYS', 'XDB')
order by owner, object_name
/

set linesize 100