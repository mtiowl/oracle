/* h:\sql\u\sql_binds.sql */
/* tested in Oracle10g    */
/* displays bind variables*/

spool c:\temp\sql_binds.out

--define sqlid=33hkfnd9v6gfv
define sqlid=&1

col    name  format a8
col    value format a40
break  on last_captured skip 1
set    verify off
set    pagesize 50

ttitle LEFT 'SQLID=&sqlid' skip ' '

set    heading off
select sql_text from v$sqlarea where sql_id='&sqlid';
set    heading on

ttitle off

select executions execs, buffer_gets gets, disk_reads reads,
       rows_processed processed, 
       substr(first_load_time,1,10)||' '||substr(first_load_time,12,5) first_load
  from v$sqlarea
 where sql_id='&sqlid';

select distinct to_char(last_captured,'YYYY-MM-DD HH24:MI:SS') last_captured,
       name,SUBSTR(value_string,1,40) value
  from dba_hist_sqlbind 
 where sql_id='&sqlid'
   and value_string IS NOT NULL
 order by 1,name;

select to_char(last_captured, 'YYYY-MM-DD HH24:MI:SS') last_captured, name, SUBSTR(value_string,1,40) value
  from v$sql_bind_capture
  where sql_id = '&sqlid'
  order by 1;
  
spool off