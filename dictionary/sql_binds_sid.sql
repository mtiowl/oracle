select s.sid, s.username, --sq.sql_text,
       s.sql_hash_value, s.sql_id, s.sql_child_number,
       spc.name,
       spc.value_string,
       last_captured
  from v$sql_bind_capture spc
      ,v$session s
      ,v$sql sq
  where s.sql_hash_value = spc.hash_value
    and s.sql_address = spc.address
    and sq.sql_id=s.sql_id
    and spc.was_captured= 'YES'
    and s.type<> 'BACKGROUND'
    and s.status='ACTIVE'
    and s.sid = &sid
/

