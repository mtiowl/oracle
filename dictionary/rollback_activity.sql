set pagesize 100
set linesize 300
col segment format a7
col program format a15 HEADING "Program"
col osuser format a8 
col sql_text HEADING "Current SQL"
col seg HEADING "Rollback|Segment"


select decode(t.xidusn, 0, 'SYSTEM'
                       ,4, 'R01'
                       ,3, 'R02'
                       ,2, 'R03'
                       ,1, 'R04'
                       ,5, 'R05'
                       ,6, 'R06'
                       ,7, 'R07'
                       ,8, 'R08') seg
      ,t.status, USED_UBLK, USED_UREC row_count--, addr
      ,s.osuser, s.username, s.program, sql.sql_text
  from v$transaction t
      ,v$session s
      ,v$sqltext sql
  where t.addr = s.taddr
    and sql.address = s.sql_address
    and s.sql_hash_value = sql.hash_value
    and sql.piece = 0
  order by xidusn, sql.piece
/

