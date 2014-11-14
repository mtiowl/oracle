set serveroutput on size 1000000 format wrapped
set pagesize 100
set linesize 300
set feedback off
set verify off
clear breaks
DEFINE p = &table_name;

DECLARE
  l_high_value   VARCHAR2(500);
  --l_range_start  VARCHAR2(500) := '2004-01-01 00:00:00';
  l_table        dba_tab_partitions.table_name%type := NULL;
  l_prev_table   dba_tab_partitions.table_name%type := NULL;
  
  l_row_total    NUMBER := 0;
  l_size_total   NUMBER := 0;
  
  l_range_start  DATE;
  l_sql          VARCHAR2(4000);
  
  l_partition_type all_part_tables.partitioning_type%type;
  l_interval       VARCHAR2(3);
  l_interval_msg   VARCHAR2(20);

BEGIN

  SELECT partitioning_type, DECODE(interval, null, 'NO', 'YES') interval_flag, decode(interval, null, ' not using INTERVAL', ' with INTERVAL')
    INTO l_partition_type, l_interval, l_interval_msg
    FROM all_part_tables 
    WHERE table_name = upper('&p');

  dbms_output.put_line (' ');
  dbms_output.put_line (' ');
  dbms_output.put_line ('Partitioning Method: '||l_partition_type||l_interval_msg);
  dbms_output.put_line ('Table Partitioned by: ');
  
  FOR crec IN (select pc.owner, tc.table_name, pc.column_position, pc.column_name, tc.data_type, tc.data_length
                 from all_part_key_columns pc
                     ,all_tab_columns tc
                 where name = upper('&p')
                   and name = tc.table_name
                   and pc.owner = tc.owner
                   and pc.column_name = tc.column_name
                 order by column_position) LOOP


     dbms_output.put_line ('   '||crec.column_name||' '||crec.data_type||'('||crec.data_length||')');
     
  END LOOP;
  
  dbms_output.put_line (' ');
  
  

  IF l_interval = 'YES' THEN
     dbms_output.put_line (rpad('TABLE_NAME', 20)||' '||rpad('PARTITION', 10)||' '||lpad('ROW_COUNT', 20)||' '||
                           lpad('SIZE_MB', 10) ||' '||lpad('RANGE_START',22) ||' '||lpad('RANGE_END',22)||' '||lpad('LAST ANALYZED', 24)||' '||lpad('COMPRESSION', 15) );
     dbms_output.put_line (rpad('-', 20, '-')||' '||rpad('-', 10, '-')||' '||lpad('-', 20, '-')||' '||
                           lpad('-', 10, '-')||' '||lpad('-',22, '-') ||' '||lpad('-',22, '-')||' '||lpad('-',25, '-')||' '||lpad('-',15, '-') );


     FOR trec IN (SELECT x.*
                    FROM (SELECT  t.table_name, p.num_rows, p.partition_name, p.interval, t.interval interval2
                                 ,p.last_analyzed, p.high_value, p.compression
                                 ,nvl(round((blocks*8192)/1024/1024,2),0) SIZE_MB
                                 ,to_date (trim ('''' from regexp_substr (
                                                 extractvalue (
                                                    dbms_xmlgen.
                                                      getxmltype (
                                                        'select high_value from all_tab_partitions where table_name='''
                                                        || p.table_name
                                                        || ''' and table_owner = '''
                                                        || p.table_owner
                                                        || ''' and partition_name = '''
                                                        || partition_name
                                                        || ''''),
                                                        '//text()'),
                                                        '''.*?''')),
                                                        'syyyy-mm-dd hh24:mi:ss') range_end
                            FROM all_tab_partitions p
                                ,dba_part_tables t
                            WHERE t.table_name IN (upper('&p'))
                              and p.table_name = t.table_name
                              and p.table_owner = t.owner) x 
                            ORDER BY 10) LOOP

       IF l_prev_table IS NULL or l_prev_table <> trec.table_name THEN
      
          IF l_prev_table is not null then
            dbms_output.put_line ('  ');
            dbms_output.put_line (rpad('Total', 20)||rpad(' ', 10)||lpad(to_char(l_row_total, '999,999,999,999'), 20)||
                             lpad(l_size_total, 10) ||lpad(' ',22) ||lpad(' ',22)||' '||rpad(' ', 24));
            dbms_output.put_line ('  ');
            dbms_output.put_line ('  ');
            dbms_output.put_line (rpad('TABLE_NAME', 20)||' '||rpad('PARTITION', 10)||' '||lpad('ROW_COUNT', 20)||' '||
                                  lpad('SIZE_MB', 10) ||' '||lpad('RANGE_START',22) ||' '||lpad('RANGE_END',22)||' '||lpad('LAST ANALYZED', 24)||' '||lpad('COMPRESSION', 15) );
            dbms_output.put_line (rpad('-', 20, '-')||' '||rpad('-', 10, '-')||' '||lpad('-', 20, '-')||' '||
                                  lpad('-', 10, '-')||' '||lpad('-',22, '-') ||' '||lpad('-',22, '-')||' '||lpad('-',25, '-')||' '||lpad('-',15, '-') );
          END IF;
       
          l_row_total  := 0;
          l_size_total := 0;
          l_table := trec.table_name;
          l_prev_table := trec.table_name;
  
       ELSE
          l_table := '  ';
       END IF;

       l_row_total := l_row_total + trec.num_rows;
       l_size_total := l_size_total + trec.size_mb;
    
       IF trec.interval = 'YES' THEN
     
          l_sql := 'SELECT to_date('''||to_char(trec.range_end, 'DD-MON-YYYY')||''', ''DD-MON-YYYY'')-'||trec.interval2||' from dual';
          --dbms_output.put_line(l_sql);
          execute immediate (l_sql)
             INTO l_range_start;
    
       END IF;
    
       l_high_value := trec.high_value;

       dbms_output.put_line (rpad(l_table, 20)||' '||
                             rpad(trec.partition_name, 10)||' '||
                             lpad(to_char(nvl(trec.num_rows,0),'999,999,999'), 20)||' '||
                             lpad(trec.size_mb, 10)||' '||
                             lpad(nvl(to_char(l_range_start, 'DD-MON-YYYY'), '<none>'),22) ||' '||
                             --lpad(to_char(to_date(substr(l_high_value, 11,19), 'YYYY-MM-DD HH24:MI:SS')-1),22)||' '||
                             lpad(to_char(trec.range_end-1, 'DD-MON-YYYY'),22)||' '||
                             lpad(to_char(trec.last_analyzed, 'YYYY-MM-DD HH24:MI:SS'),24)||' '||
                             lpad(trec.compression,15)
                            );
       --l_range_start := substr(l_high_value, 11,19);
     END LOOP;
  
  
  
  ELSE   -- NON interval partitioned tables

       dbms_output.put_line (rpad('TABLE_NAME', 20)||' '||rpad('PARTITION', 10)||' '||lpad('ROW_COUNT', 20)||' '||
                             lpad('SIZE_MB', 10)   ||' '||lpad('RANGE_END',22)||' '||lpad('LAST ANALYZED', 24)||' '||lpad('COMPRESSION', 15) );
       dbms_output.put_line (rpad('-', 20, '-')||' '||rpad('-', 10, '-')||' '||lpad('-', 20, '-')||' '||
                             lpad('-', 10, '-')||' '||lpad('-',22, '-')||' '||lpad('-',25, '-')||' '||lpad('-',15, '-') );


  
       FOR trec IN (SELECT  t.table_name, p.num_rows, p.partition_name
                                   ,p.last_analyzed, p.high_value, p.compression
                                   ,nvl(round((blocks*8192)/1024/1024,2),0) SIZE_MB
                              FROM all_tab_partitions p
                                  ,dba_part_tables t
                              WHERE t.table_name IN (upper('&p'))
                                and p.table_name = t.table_name
                                and p.table_owner = t.owner) LOOP
  
         IF l_prev_table IS NULL or l_prev_table <> trec.table_name THEN
        
            IF l_prev_table is not null then
              dbms_output.put_line ('  ');
              dbms_output.put_line (rpad('Total', 20)||rpad(' ', 10)||lpad(to_char(l_row_total, '999,999,999,999'), 20)||
                               lpad(l_size_total, 10) ||lpad(' ',22) ||lpad(' ',22)||' '||rpad(' ', 24));
              dbms_output.put_line ('  ');
              dbms_output.put_line ('  ');
              dbms_output.put_line (rpad('TABLE_NAME', 20)||rpad('PARTITION', 10)||lpad('ROW_COUNT', 20)||
                                    lpad('SIZE_MB', 10) ||lpad('RANGE_END',22)||' '||lpad('LAST ANALYZED', 24)||' '||lpad('COMPRESSION', 15) );
              dbms_output.put_line (rpad('-', 20, '-')||rpad('-', 10, '-')||lpad('-', 20, '-')||
                                    lpad('-', 10, '-') ||lpad('-',22, '-')||lpad('-',25, '-')||lpad('-',15, '-') );
            END IF;
         
            l_row_total  := 0;
            l_size_total := 0;
            l_table := trec.table_name;
            l_prev_table := trec.table_name;
    
         ELSE
            l_table := '  ';
         END IF;
  
         l_row_total := l_row_total + trec.num_rows;
         l_size_total := l_size_total + trec.size_mb;
      
         l_high_value := trec.high_value;
  
         dbms_output.put_line (rpad(l_table, 20)||' '||
                               rpad(trec.partition_name, 10)||' '||
                               lpad(to_char(nvl(trec.num_rows,0),'999,999,999'), 20)||' '||
                               lpad(trec.size_mb, 10)||' '||
                               lpad(l_high_value,22)||' '||
                               lpad(to_char(trec.last_analyzed, 'YYYY-MM-DD HH24:MI:SS'),24)||' '||
                               lpad(trec.compression,15)
                              );
     END LOOP;  
  
  
  END IF;  /* IF l_interval = 'YES .. */
  
  -- Finaly totals
  dbms_output.put_line (rpad('-', 31, '-')||' '||lpad('-', 20, '-')||' '||lpad('-', 10, '-') );
  dbms_output.put_line (rpad('Total', 23)||rpad(' ', 10)||lpad(to_char(l_row_total, '999,999,999,999'), 20)||
  lpad(l_size_total, 10) ||lpad(' ',22) ||lpad(' ',22)||' '||rpad(' ', 24));
  dbms_output.put_line ('  ');
  dbms_output.put_line ('  ');

end;
/

set linesize 100
set verify on