prompt ********************
prompt  Locked Objects
prompt ********************
set linesize 300
col OBJECT_WAITED_ON format a40
col obj_owner format a15
col object_name format a30
col object_type format a20

SELECT distinct owner OBJ_OWNER,
       object_name, object_type, s.osuser locked_by_os_user, s.sid, s.username locked_by_db_username, s.program,
DECODE(l.block,
  0, 'Not Blocking',
  1, 'Blocking',
  2, 'Global') STATUS,
  DECODE(v.locked_mode,
    0, 'None',
    1, 'Null',
    2, 'Row-S (SS)',
    3, 'Row-X (SX)',
    4, 'Share',
    5, 'S/Row-X (SSX)',
    6, 'Exclusive', TO_CHAR(lmode)
  ) MODE_HELD
FROM gv$locked_object v, dba_objects d,
gv$lock l, gv$session s
WHERE v.object_id = d.object_id
AND (v.object_id = l.id1)
AND v.session_id = s.sid
ORDER BY 4
/

prompt ********************
prompt  LIbrary Cache Locks
prompt ********************
SELECT /*+ ordered */
     w1.sid  waiting_session,
     w1.username who,
      w1.sql_id SQL_ID,
     h1.sid  holding_session,
     w.kgllktype lock_or_pin,
     w.kgllkhdl address,
     DECODE(h.kgllkmod,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown') mode_held,
        DECODE(w.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown') mode_requested,
     h1.sql_hash_value  ,
     lock_id1 object_waited_on
FROM
     dba_kgllock w,
     dba_kgllock h,
     v$session w1,
     v$session h1 ,
     dba_lock_internal dl
WHERE
     (((h.kgllkmod != 0) AND (h.kgllkmod != 1)
   AND      ((h.kgllkreq = 0) OR (h.kgllkreq = 1)))
   AND  (((w.kgllkmod = 0) OR (w.kgllkmod= 1))      AND ((w.kgllkreq != 0)
   AND (w.kgllkreq != 1))))
    AND  w.kgllktype    =  h.kgllktype   AND  w.kgllkhdl        =  h.kgllkhdl
AND  w.kgllkuse=w1.saddr   AND  h.kgllkuse=h1.saddr
and dl.mode_requested<>'None'
and dl.mode_requested<>dl.mode_held
and w1.sid=dl.SESSION_ID
/
set linesize 100