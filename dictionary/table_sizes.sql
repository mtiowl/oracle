set feeedback off
set verify off
set serveroutput on size 1000000 format wrapped
set linesize 300
spool c:\temp\table_sizes.out

DECLARE

  CURSOR get_extents (p_tablespace VARCHAR2) IS
    SELECT e.segment_name, sum(e.blocks) total_blocks, count(*) total_extents
      FROM dba_extents e
      WHERE tablespace_name = p_tablespace
        AND e.segment_type = 'TABLE'
      HAVING (   sum(e.blocks) > 1000 AND count(*) > 1  )
      GROUP BY e.segment_name
      ORDER BY total_blocks DESC;

   CURSOR get_tables (p_tablespace VARCHAR2, p_table_name VARCHAR2) IS
         SELECT owner, nvl(empty_blocks,0) empty_blocks
               ,nvl(chain_cnt,0) chain_cnt, nvl(next_extent, 0) next_extent
               ,num_rows
               ,pct_free
           FROM all_tables
           WHERE table_name = p_table_name
             AND tablespace_name = p_tablespace
             AND num_rows > 0;


  l_block_size          NUMBER;
  l_tablespace          VARCHAR2(500) := '&tablespace';
  l_extent_mgmt         dba_tablespaces.extent_management%type;
  l_segment_space_mgmt  dba_tablespaces.segment_space_management%type;

BEGIN

   SELECT to_number(value)
     INTO l_block_size
     FROM v$parameter
     WHERE upper(name) = 'DB_BLOCK_SIZE';
     
   SELECT extent_management, segment_space_management 
     INTO l_extent_mgmt, l_segment_space_mgmt
     FROM dba_tablespaces
     WHERE tablespace_name = l_tablespace;


   dbms_output.put_Line(' ');
   dbms_output.put_Line(' ');
   dbms_output.put_line('Block Size: '||l_block_size);
   dbms_output.put_line('Extent Management: '||l_extent_mgmt);
   dbms_output.put_Line('Segment Space Management: '||l_segment_space_mgmt);
   dbms_output.put_Line(' ');
   
   dbms_output.put_line (rpad('Owner', 20)||rpad('Table',30)||lpad('Total Extents', 15)||lpad('Total BLocks', 15)||lpad('Empty Blocks', 15)||lpad('Total Size (MB)',17)||lpad('Chained Rows',15)||lpad('Chained %', 15)||lpad('PCT Free',15)||lpad('Next Extent (MB)', 18));
   
   FOR erec IN get_extents (l_tablespace) LOOP
   
      FOR trec IN get_tables (l_tablespace, erec.segment_name) LOOP
   
         BEGIN
            dbms_output.put_line (rpad(trec.owner, 20)||
                                  rpad(erec.segment_name,30)||
                                  lpad(erec.total_extents, 15)||
                                  lpad(erec.total_blocks, 15)||
                                  lpad(trec.empty_blocks, 15)||
                                  lpad(to_char(round((erec.total_blocks*l_block_size)/1000000,1),'999,999,999.00'), 17)||
                                  lpad(trec.chain_cnt,15)||
                                  lpad(ROUND( (trec.chain_cnt/trec.num_rows)*100,2), 15)||'%'||
                                  lpad(trec.pct_free,15)||
                                  lpad(to_char(round(trec.next_extent/1000000,1),'999,999.00'), 18));
         EXCEPTION
           WHEN others THEN
              dbms_output.put_line ('Error:  Table: '||erec.segment_name||'  total_blocks: '||erec.total_blocks||' chained count: '||trec.chain_cnt||' Row Count: '||trec.num_rows);
         END;
      END LOOP;

   END LOOP;



END;
/
spool off
set linesize 100
set feeedback on
set verify on