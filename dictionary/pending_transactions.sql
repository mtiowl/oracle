select s.sid
      ,s.serial#
      ,s.username
      ,s.machine
      ,s.status session_status
      ,s.lockwait
      ,t.used_ublk
      ,t.used_urec
      ,t.start_time
      ,sql.sql_text
from v$transaction t
    ,v$session s
    ,v$sql sql
WHERE t.addr = s.taddr
  and s.SQL_ADDRESS = sql.address(+)
  and s.SQL_HASH_VALUE = sql.HASH_VALUE(+)
/
