
set linesize 100
col sql_text format a100
column username format a10
column osuser format a10
column program format a15

select sesion.sid
      ,serial#
      ,sesion.username
      ,sesion.OSUSER
      ,sesion.program
--      ,optimizer_mode
--      ,hash_value
--      ,address
--      ,cpu_time
--      ,elapsed_time
       ,sql_text
  from v$sqlarea sqlarea, v$session sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   --and sesion.username = upper('&username')
   --and upper(sesion.osuser) = upper('os_user')
--   and sqlarea.hash_value = &hash_value
 order by sesion.osuser, sid
/
