col username format a20
col machine format a30
set linesize 300

SELECT s.username, s.machine, i.*
  FROM V$SESS_IO i
      ,V$SESSION s
  WHERE i.sid = s.sid
  ORDER BY s.username
/

set linesize 100