@datetime
SET SERVEROUTPUT OFF
@"C:\Documents and Settings\E40025\My Documents\Oracle\DBA\dbms_jobs\test_proc.sql"

@"C:\Documents and Settings\E40025\My Documents\Oracle\DBA\dbms_jobs\submit_test_job.sql"

TTITLE SKIP 3 LEFT 'DBMS_JOB Test' - 
SKIP 1 LEFT '--------------------' SKIP 2
REM "C:\Documents and Settings\E40025\My Documents\Oracle\DBA\dbms_jobs\job_test_list.sql"
@"C:\Documents and Settings\E40025\My Documents\Oracle\DBA\dbms_jobs\job_list.sql"


SET SERVEROUTPUT ON SIZE 1000000 format wrapped 


DECLARE

   l_value     mti_test_table.message%type;
   l_count     NUMBER;
   l_end_time  DATE;

BEGIN

  l_value := NULL;
  l_count := 0;
  l_end_time := sysdate+(20*(1/24/60/60));  --waiting 20 seconds

  WHILE sysdate <= l_end_time AND l_value IS NULL LOOP

     BEGIN
       SELECT message
         INTO l_value
         FROM mti_test_table;
     
     EXCEPTION
       WHEN no_data_found THEN
          l_value := null;
     END;

     l_count := l_count + 1;

  END LOOP;

  dbms_output.put_line ('');
  IF l_value IS NOT NULL THEN
     dbms_output.put_line ('   >>> DBMS_JOB was successful');
  ELSE
     dbms_output.put_line ('   >>> DBMS_JOB failed');
  END IF;
  dbms_output.put_line ('');
  
END;
/

DROP TABLE mti_test_table;
DROP PROCEDURE mti_test;

@date