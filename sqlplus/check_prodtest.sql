spool C:\temp\check_prodtest.out

TTITLE CENTER '********   CL2PRPT   ********' SKIP 1 -
CENTER ============================= SKIP 1 - LEFT 'Database Link Report' - 
SKIP 1 LEFT '--------------------' SKIP 2

connect cl2prp/fullt3st@cl2prpt

set feedback off
set linesize 130
column owner format a20
column db_link format a35
column host format a10

select owner, db_link, username, host, to_char(created, 'DD-MON-YYYY') created
  FROM all_db_links
  WHERE upper(host) like '%P'
UNION
SELECT ' ' as owner, ' ' as db_link, ' ' as username, ' ' as host, null as created
  FROM dual
/


TTITLE SKIP 4 CENTER '********   PSOLPT   ********' SKIP 1 -
CENTER ============================= SKIP 1 - LEFT 'Database Link Report' - 
SKIP 1 LEFT '--------------------' SKIP 2
connect custpro/fullt3st@psolpt

set linesize 130
column owner format a20
column db_link format a35
column host format a10

select * 
  FROM all_db_links
  WHERE upper(host) like '%P'
UNION
SELECT ' ' as owner, ' ' as db_link, ' ' as username, ' ' as host, null as created
  FROM dual
/

@check_dbms_job.sql


TTITLE SKIP 4 CENTER '********   EDOPT   ********' SKIP 1 -
CENTER ============================= SKIP 1 - LEFT 'Database Link Report' - 
SKIP 1 LEFT '--------------------' SKIP 2
connect edoadmin/fullt3st@edopt

set linesize 130
column owner format a20
column db_link format a35
column host format a10

select * 
  FROM all_db_links
  WHERE upper(host) like '%P'
UNION
SELECT ' ' as owner, ' ' as db_link, ' ' as username, ' ' as host, null as created
  FROM dual
/

@check_dbms_job.sql


TTITLE SKIP 4 CENTER '********   ERSPT   ********' SKIP 1 -
CENTER ============================= SKIP 1 - LEFT 'Database Link Report' - 
SKIP 1 LEFT '--------------------' SKIP 2
connect eradmin/fullt3st@erspt

set linesize 130
column owner format a20
column db_link format a35
column host format a10

select * 
  FROM all_db_links
  WHERE upper(host) like '%P'
UNION
SELECT ' ' as owner, ' ' as db_link, ' ' as username, ' ' as host, null as created
  FROM dual
/


spool off

host move "c:\temp\check_prodtest.out" "c:\Documents and Settings\E40025\My Documents\Oracle\DBA\sqlplus\check_prodtest.out"

TTITLE OFF
BTITLE OFF
