select a.owner||'.'||a.object_name "OBJECT",
       DECODE(b.type,'TM','TM-Table',
                     'MR','MR-Media Recovery',
                     'TX','TX-Row',b.type) "LOCK TYPE",
       c.username,
       c.osuser,
       TO_CHAR(c.sid)||','||TO_CHAR(c.serial#) "sid,serial",
       ROUND(ctime/60) minutes
  from dba_objects a, v$lock b, v$session c
where a.object_id=b.id1
   and a.owner<>'SYS'
   and b.sid=c.sid;
