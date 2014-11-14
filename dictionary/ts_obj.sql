select object_name, object_type, status from user_objects
where status = 'INVALID'
  and object_name NOT IN (select name from all_source where upper(text) like '%TIMESTAMP%'and owner = user)
/
