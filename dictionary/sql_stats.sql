REM
REM display disk reads, buffer gets for a given SQL (Hash Value)
REM

select executions, buffer_gets, disk_reads, rows_processed
 from v$sqlarea
 where hash_value = &sql_hash_value
/
