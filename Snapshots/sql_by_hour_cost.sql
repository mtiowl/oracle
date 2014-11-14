SET TERMOUT OFF;
COLUMN script_name_col NEW_VALUE script_name;
SELECT CASE
  WHEN TO_NUMBER(SUBSTR(version, 0, INSTR(version, '.')-1)) >= 10
  THEN 'includes/sql10_by_hour_cost.sql'
  ELSE
     CASE WHEN TO_NUMBER(SUBSTR(version, 0, INSTR(version, '.')-1)) <= 8
     THEN 'includes/sql8_by_hour.sql'
     ELSE 'includes/sql9_by_hour.sql'
  END
END AS script_name_col
FROM v$instance;

SET TERMOUT ON;

@&script_name &1 &2 &3