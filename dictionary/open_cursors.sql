 select *
   from ( select ss.value, sn.name, ss.sid, s.username, s.osuser, s.module, s.program, s.logon_time
            from v$sesstat ss
                ,v$statname sn
                ,v$session s
            where ss.statistic# = sn.statistic#
              and sn.name like '%opened cursors current%'
              and ss.sid = s.sid
            order by value desc)
   where rownum < 11
/
