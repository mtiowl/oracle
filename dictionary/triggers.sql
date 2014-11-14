COL owner FORMAT a20
COL triggering_event FORMAT a30
SET LINESIZE 300

select owner, trigger_name, triggering_event, status
from all_triggers
where table_name = upper('&table_name')
/

SET LINESIZE 100