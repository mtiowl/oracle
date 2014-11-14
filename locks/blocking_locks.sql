select l1.sid||' ('||s1.username||' - '||s1.osuser||') IS BLOCKING '||l2.sid||' ('||s2.username||' - '||s2.osuser||')'
  from v$lock l1
      ,v$session s1
      ,v$lock l2
      ,v$session s2
  where l1.block =1 and l2.request > 0
  and l1.id1=l2.id1
  and l1.id2=l2.id2
  and l1.sid = s1.sid
  and l2.sid = s2.sid
/
