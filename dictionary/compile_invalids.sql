SET SCAN ON

BEGIN
  dbms_utility.compile_schema( upper( '&schema_name' ) );
END;
/


SELECT object_name, object_type, status
  FROM all_objects
  WHERE status = 'INVALID';

set scan off