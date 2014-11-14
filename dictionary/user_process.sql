select s.username
      ,ltrim(rtrim(lower(global_name))) db_name
      ,s.sid, s.serial#, p.pid, p.spid "OS Process (spid)", s.process
  FROM V$SESSION s
      ,v$process p
      ,global_name
  WHERE s.paddr = p.addr
    AND s.username = 'ACCT_XTRACT'
/
