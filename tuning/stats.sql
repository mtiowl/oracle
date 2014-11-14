SHOW PARAMETER OPTIMIZER_MODE



select table_name, last_analyzed
from all_tables
where table_name = upper('&table_name')
/
