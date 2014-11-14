set pagesize 100
set linesize 300



select r.name segment, rs.*
      ,s.osuser, s.username, s.program
  from v$transaction t
      ,v$session s
      ,v$rollstat rs
      ,v$rollname r
  where t.addr = s.taddr
    and rs.usn = t.xidusn
    and rs.usn = r.usn
  order by xidusn
/



