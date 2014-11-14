SET TERMOUT OFF;
COLUMN script_name_col NEW_VALUE script_name;
SELECT CASE
	WHEN LENGTH('&1') = 13
	THEN 'includes/idstats.sql'
	ELSE 'includes/hashstats.sql'
	END AS script_name_col
FROM dual;
SET TERMOUT ON;

------------------------------------------------------------

SET PAGESIZE 50

@&script_name &1