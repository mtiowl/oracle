SET HEAD OFF
SET VERIFY OFF
SET FEEDBACK OFF
set linesize 300

DEFINE s_id = &SQL_ID

select plan_table_output
  from TABLE( dbms_xplan.display_AWR ( '&s_id', null, null, 'ADVANCED') )
/


SET HEAD ON
--break on last_captured

--select distinct to_char(last_captured,'YYYY-MM-DD HH24:MI:SS') last_captured,
--       name,SUBSTR(value_string,1,40) value
--  from dba_hist_sqlbind 
-- where sql_id='&s_id'
--   and value_string IS NOT NULL
-- order by 1,name;


SET VERIFY ON