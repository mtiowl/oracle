col user_name new_value user_name
col db_name new_value db_name
col db_name format a20

select lower(user) user_name
      ,ltrim(rtrim(lower(global_name))) db_name 
      ,s.sid, s.serial#, p.pid, p.spid, s.process
  FROM V$SESSION s
      ,v$process p
      ,global_name
  WHERE audsid = SYS_CONTEXT('userenv','sessionid')
    AND s.paddr = p.addr;

set sqlprompt "&user_name@&db_name> "

