set serveroutput on size 1000000
set linesize 300

declare
  l_owner         dba_segments.owner%type := '&owner';
  l_segment_name  dba_segments.segment_name%type := '&table_name';
  l_segment_type  dba_segments.segment_type%type := 'TABLE';
  
  l_tablespace     dba_tablespaces.tablespace_name%type;
  l_segment_space_management dba_tablespaces.segment_space_management%type;
  unf number; 
  unfb number; 
  fs1 number; 
  fs1b number; 
  fs2 number; 
  fs2b number; 
  fs3 number; 
  fs3b number; 
  fs4 number; 
  fs4b number; 
  full number; 
  fullb number; 
  l_total_blocks      NUMBER;
  l_total_bytes       NUMBER;
  l_unused_blocks     NUMBER;
  l_unused_bytes      NUMBER;
  l_last_extent_file  NUMBER;
  l_last_extent_block NUMBER;
  l_last_block        NUMBER;
begin 

  SELECT ts.tablespace_name, SEGMENT_SPACE_MANAGEMENT 
    INTO l_tablespace, l_segment_space_management
    from dba_tablespaces ts
        ,dba_tables t
    WHERE ts.tablespace_name = t.tablespace_name
      AND t.table_name = l_segment_name;
      
  IF l_segment_space_management = 'AUTO' THEN
     dbms_space.space_usage(segment_owner => l_owner
                           ,segment_name  => l_segment_name 
                           ,segment_type  => l_segment_type
                           ,unformatted_blocks =>  :unf
                           ,unformatted_bytes  =>  :unfb
                           ,fs1_blocks  => fs1
                           ,fs1_bytes   => fs1b
                           ,fs2_blocks  => fs2
                           ,fs2_bytes   => fs2b
                           ,fs3_blocks  => fs3
                           ,fs3_bytes   => fs3b
                           ,fs4_blocks  => fs4
                           ,fs4_bytes   => fs4b
                           ,full_blocks => full
                           ,full_bytes  => fullb);  
  END IF;
  
  DBMS_SPACE.UNUSED_SPACE (segment_owner => l_owner
                          ,segment_name => l_segment_name
                          ,segment_type => l_segment_type
                          ,total_blocks => l_total_blocks
                          ,total_bytes  => l_total_bytes
                          ,unused_blocks => l_unused_blocks
                          ,unused_bytes  => l_unused_bytes
                          ,last_used_extent_file_id => l_last_extent_file
                          ,last_used_extent_block_id => l_last_extent_block
                          ,last_used_block => l_last_block
                          ,partition_name => null
                          );

  dbms_output.put_line (rpad('OWNER', 20)||' '||rpad('SEGMENT_NAME', 30)||' '||rpad('SEGMENT_TYPE',20)||' '||lpad('TOTAL_BLOCKS',15)||' '||lpad('TOTAL_BYTES_MB', 15)||' '||
                        lpad('UNUSED_BLOCKS', 15)||lpad('UNUSED_BYTES_MB', 18)||' '||lpad('LAST_EXTENT_FILE', 20)||' '||lpad('LAST_EXTENT_BLOCK',20)||' '||lpad('LAST_BLOCK', 15));

  dbms_output.put_line (rpad('-', 20, '-')||' '||rpad('-', 30, '-')||' '||rpad('-',20,'-')||' '||lpad('-',15,'-')||' '||lpad('-', 15, '-')||' '||
                        lpad('-', 15, '-')||' '||lpad('-', 18, '-')||' '||lpad('-', 20, '-')||' '||lpad('-',20,'-')||' '||lpad('-', 15, '-'));

  dbms_output.put_line (rpad(l_owner, 20)||' '||rpad(l_segment_name, 30)||' '||rpad(l_segment_type,20)||' '||lpad(l_total_blocks,15)||' '||lpad(round((l_total_bytes/1024/1024),2), 15)||' '||
                        lpad(l_unused_blocks, 15)||' '||lpad(round((l_unused_bytes/1024/1024),2), 18)||' '||lpad(l_last_extent_file, 20)||' '||lpad(l_last_extent_block,20)||' '||lpad(l_last_block, 15));

                       
end; 
/ 
