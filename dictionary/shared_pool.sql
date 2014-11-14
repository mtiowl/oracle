select name,
       round(bytes/1024/1024,2) mbytes,
       mbytes_tot,
       round(round(bytes/1024/1024,2)/mbytes_tot*100) pct,
       round(to_number(value)/1024/1024) shared_pool_size
 from v$sgastat,
     (select round(sum(bytes)/1024/1024) mbytes_tot
        from v$sgastat
        where pool = 'shared pool'),
     (select value , rownum
       from v$parameter
       where name = 'shared_pool_size' )
 where pool = 'shared pool'
/
