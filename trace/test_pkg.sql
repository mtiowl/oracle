DROP TABLE mti_views;
CREATE TABLE mti_views AS
  SELECT view_name, text_length, owner
    FROM all_views;

DROP TABLE mti_objects;
CREATE TABLE mti_objects AS
  SELECT object_id, object_name, owner
    FROM all_objects;


CREATE OR REPLACE PACKAGE trace_test IS

  PROCEDURE run;


END trace_test;
/
show errors



CREATE OR REPLACE PACKAGE BODY trace_test IS

  -- *****************************************************************************************
  --  Helper procedure to fetch all objects that the user can see
  -- *****************************************************************************************
  PROCEDURE fetch_objects IS
  
    CURSOR get_objects IS
       SELECT object_id, object_name, owner
         FROM mti_objects;
  
  BEGIN
  
    FOR orec IN get_objects LOOP
    
      dbms_output.put_line (rpad(orec.object_id, 20)||rpad(orec.object_name, 40)||rpad(orec.owner, 20) );
    
    END LOOP;
  
  END fetch_objects;


  -- *****************************************************************************************
  --  Helper procedure to fetch all views that the user can see
  -- *****************************************************************************************
  PROCEDURE fetch_views IS
    
    CURSOR get_views IS
       SELECT view_name, text_length, owner
         FROM mti_views;
  
  BEGIN

    FOR vrec IN get_views LOOP
    
      dbms_output.put_line (rpad(vrec.view_name, 20)||rpad(vrec.owner, 40)||rpad(vrec.text_length, 20) );
    
    END LOOP;
  
  END fetch_views;
  
  
  -- *****************************************************************************************
  --  Driver Procedure
  -- *****************************************************************************************
  PROCEDURE run IS
  
  
  BEGIN
  
    fetch_objects;
    fetch_views;
  
  
  END run;

END trace_test;
/
show errors