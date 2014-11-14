
set linesize 300
set pagesize 0
set head off
set feedback off
set verify off
column USER new_value SCHEMA_NAME noprint

SELECT user
  FROM dual;

spool c:\temp\source\&&schema_name\&&1..pkg

SELECT 'CREATE OR REPLACE ' FROM dual;

select text
  FROM user_source
  WHERE name = UPPER('&1')
    AND type = 'PACKAGE'
  order by line
/
select '/' FROM dual;

SELECT 'CREATE OR REPLACE ' FROM dual;
select text
  FROM user_source
  WHERE name = UPPER('&1')
    AND type = 'PACKAGE BODY'
  order by line
/

select '/' FROM dual;

spool off
set linesize 100
set pagesize 50