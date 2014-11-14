col blocked_user format a15
col blocking_user format a15
col blocking_osuser format a10
col blocked_osuser format a10
col blocking_program format a20
col object_name format a30
set linesize 300

select l1.sid BLOCKING_sid, s1.username blocking_user, s1.osuser blocking_osuser, s1.status blocking_session_status, s1.program blocking_program, s1.sql_id
            ,' || ' "<-->"
            ,l2.sid blocked_sid, s2.username blocked_user, s2.osuser blocked_osuser, s2.status blocked_session_status, s2.program blocked_program, s2.sql_id
            --,s2.event
            ,substr(s2.event,1,30) event
            ,o.object_name
            ,s2.row_wait_row#
            ,ROUND(s2.seconds_in_wait/60,0) minutes
       from v$lock l1
           ,v$session s1
           ,v$lock l2
           ,v$session s2
           ,dba_objects o
       where l1.block =1 and l2.request > 0
         and l1.id1=l2.id1
         and l1.id2=l2.id2
         and l1.sid = s1.sid
         and l2.sid = s2.sid
         and o.object_id = s2.row_wait_obj#
/

column object_name format a40

Prompt >>> Locked Objects
set linesize 300
col locked_mode format a15
select o.object_name, lo.oracle_username, lo.process
      ,decode(lo.locked_mode, 0, 'None',
                              1, 'Null (NULL)',
                              2, 'Row-S (SS)',
                              3, 'Row-X (SX)',
                              4, 'Share (S)',
                              5, 'S/Row-X (SSX)',
                              6, 'Exclusive (X)',
                              lo.locked_mode) locked_mode
       ,s.sid, s.osuser
from v$locked_object lo
    ,dba_objects o
    ,v$session s
where o.object_id = lo.object_id
  and lo.session_id = s.sid
/