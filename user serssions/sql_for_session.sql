--USE to get the info on a top Oracle Server Process by SPID (UX PID)
SELECT osuser, s.program, 
      a.terminal,
      'KILL SESSION ''' || s.sid || ',' || s."SERIAL#" || '''' as "ALTER SYSTEM", 
      s.sid as "Oracle Session",
      s."SERIAL#", 
      a.pid as "Oracle ID", 
      a.spid as "Oracle OS PID", 
      a.username, s.username, s.osuser,
      s.process as "Remote PID", 
      s.sql_address, s.sql_hash_value,
      q.sql_id, q.sql_text, q.disk_reads
FROM v$session s, 
     v$sql q, 
     v$process a 
WHERE s.sql_address = q.address
  AND s.sql_hash_value = q.hash_value
  AND a.addr = s.paddr
  and a.spid = '15083' –This SPID is one of the Current you are looking at for CSS
ORDER BY s.username desc;
