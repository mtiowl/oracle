SET LINESIZE 120
set head off
set pagesize 0
set verify off
define tbl = &table_name
spool x.sql
SELECT 'SELECT max(cnt), min(cnt), round(avg(cnt), 2) avg FROM (select count(*) cnt, dbms_rowid.rowid_block_number(rowid)
          from &tbl
          group by dbms_rowid.rowid_block_number(rowid) ) x;'
 FROM DUAL
/

spool off
set linesize 100
set head on
set pagesize 300
@x.sql