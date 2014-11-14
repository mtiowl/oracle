col "Bind Aware" format a10
col "Bind Sensitive" format a20
set linesize 200

select sql_id, executions, substr(sql_text, 1, 30) sql_txt, is_bind_sensitive "Bind Sensitive", is_bind_aware "Bind Aware", child_number
  from v$sql 
  where sql_id = '&sql_id';
