SELECT   username, sql_text, ROUND((elapsed_time/1000000)/60,2) as elapsed_time_minutes, executions, optimizer_cost, loads,
         fetches, rows_processed,
         --DECODE (command_type,
         --        2, 'Insert',
         --        3, 'Select',
         --        6, 'Update',
         --        7, 'Delete',
         --        26, 'Lock Table',
         --        35, 'Alter Database',
         --        42, 'Alter Session',
         --        44, 'Commit',
         --        45, 'Rollback',
         --        46, 'Savepoint',
         --        47, 'Begin/Declare',
         --        command_type
         --       ) AS cmdtype,
         first_load_time, last_load_time, module
    FROM v$sql, v$session_longops
   --longops is a view of statements that took longer than 6 seconds
WHERE    sql_address(+) = address AND sql_hash_value(+) = hash_value
  AND username is not null
ORDER BY elapsed_time DESC, executions, address, hash_value, child_number;

