
set linesize 300
set pagesize 0
set head off
set feedback off
set verify off
column USER new_value SCHEMA_NAME noprint

SELECT user
  FROM dual;

spool c:\temp\source\&&schema_name\get_all_packages.sql

SELECT '@get_source.sql '||object_name
  FROM user_objects
  WHERE object_type = 'PACKAGE';

spool off

spool c:\temp\source\&&schema_name\create_all.sql

--SELECT 'DROP TABLE user_source_back;' FROM dual;
--SELECT 'CREATE TABLE user_source_back AS SELECT * FROM user_source;' from dual;
SELECT 'SET SCAN OFF' from dual;

SELECT '@'||object_name||'.pkg'
  FROM user_objects
  WHERE object_type = 'PACKAGE';

spool off


set linesize 100
set pagesize 50