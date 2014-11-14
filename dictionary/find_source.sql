define obj = &Object_name
define lineno = &Line
set linesize 300
set scan on
col text format a150

select line, text
from all_source
where name = upper('&obj')
  and line between &lineno-5 and &lineno+5
/

set line 100