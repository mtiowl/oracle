set serveroutput on size 1000000
SET LINESIZE 150
COLUMN spid FORMAT A10
COLUMN username FORMAT A20
COLUMN program FORMAT A15

DECLARE
  CURSOR get_sessions IS
   SELECT s.sid
      ,s.serial#
      ,p.spid
      ,p.addr
      ,s.username
      --,s.OSUSER
      ,s.terminal
      --,s.machine
      ,s.program
      ,s.type
      ,s.status
      ,CPU_TIME/1000 cpu_time_seconds
      ,ELAPSED_TIME/1000 elapsed_time_seconds
      -- 10g and later ,user_io_wait_time/1000 user_io_wait_seconds
      ,SQLTYPE        
      ,REMOTE         
      ,PLAN_HASH_VALUE
      ,ltrim(rtrim(UPPER(gn.global_name))) db_name
      ,sysdate sample_date
      ,sq.sql_text 
      ,s.sql_address
FROM   v$session s
      ,v$process p
      ,v$sql sq
      ,global_name gn
WHERE  s.type != 'BACKGROUND'
  AND p.addr = s.paddr 
  AND p.addr = s.paddr
  AND s.SQL_ADDRESS = sq.ADDRESS(+)
  AND upper(s.program) = 'MSACCESS.EXE';
  
  CURSOR get_sql (p_address RAW) IS
    SELECT sql_text
      FROM v$sqltext
      WHERE address = p_address
      ORDER BY hash_value, address, piece;

   l_sql   access_monitor.sql_text%type;
   l_position NUMBER;
   l_length   NUMBER;

BEGIN

  FOR srec IN get_sessions LOOP
  
      dbms_output.put_line ('address: '||srec.addr);
      
      FOR sqlrec IN get_sql (srec.sql_address) LOOP

        l_sql := l_sql || sqlrec.sql_text;      
      
      END LOOP;
  
      dbms_output.put_line('username: '||srec.username);
      
      l_position := 1;
      l_length := 255;
      IF LENGTH(l_sql) > 255 THEN
         WHILE l_position < LENGTH(l_sql) LOOP
             dbms_output.put_line (substr(l_sql, l_position, l_length) );
             l_position := l_position + 255;
         END LOOP;
      ELSE
          dbms_output.put_line('sql: '||l_sql);
      END IF;
  END LOOP;

END;
/
