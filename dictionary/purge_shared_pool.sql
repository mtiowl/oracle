select 'exec sys.dbms_shared_pool.purge('''||address||','||hash_value||''',''C'');'
 from v$sqlarea where sql_id ='9uz15wup9tyyv';

exec sys.dbms_shared_pool.purge('000000006880EDD0,710911064', 'C');