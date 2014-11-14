SET SERVEROUTPUT ON SIZE 1000000 FORMAT TRUNCATED
SET LINESIZE 300
SET TRIM ON
SPOOL c:\temp\x.sql

DECLARE
  l_temp  all_source.text%type;
  
BEGIN

  FOR srec IN (select object_name FROM user_objects WHERE object_type = 'PACKAGE' AND object_name = 'PCPM_SETTLEMENT_USAGE') LOOP
  
      dbms_output.put_line ('CREATE OR REPLACE PACKAGE ');
      FOR pkg_rec IN (SELECT text
                        FROM all_source
                        WHERE type = 'PACKAGE'
                          AND name = srec.object_name
                        ORDER BY line) LOOP
          
         dbms_output.put_line (pkg_rec.text);
  
      END LOOP;
      dbms_output.put_line (CHR(10)||'/'||chr(10));
      
      dbms_output.put_line ('CREATE OR REPLACE PACKAGE BODY ');
      FOR pkg_rec IN (SELECT text
                        FROM all_source
                        WHERE type = 'PACKAGE BODY'
                          AND name = srec.object_name
                        ORDER BY line) LOOP
                        
         dbms_output.put_line (pkg_rec.text);
         
      END LOOP;
      
      dbms_output.put_line (CHR(10)||'/'||chr(10));
  
  END LOOP;


END;
/

SPOOL OFF