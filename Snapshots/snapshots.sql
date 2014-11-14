SET TERMOUT OFF;
COLUMN script_name_col NEW_VALUE script_name;
SELECT CASE
	WHEN TO_NUMBER(SUBSTR(version, 0, INSTR(version, '.')-1)) >= 10
	THEN 'includes/snapshots10.sql'
	ELSE 'includes/snapshots9.sql'
	END AS script_name_col
FROM v$instance;
SET TERMOUT ON;

------------------------------------------------------------

SET PAGESIZE 50
break on report
col snaps   format 99990
col min_id  format 999990
col max_id  format 99990
col min_time format a8
col max_time format a8

compute sum of snaps on report

@&script_name