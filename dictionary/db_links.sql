set linesize 300
column owner format a20
column db_link format a20
column host format a10

select * from dba_db_links
/

set linesize 100