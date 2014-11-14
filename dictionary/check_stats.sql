select owner, table_name, partition_name, last_analyzed, stale_stats
 from DBA_TAB_STATISTICS
 where stale_stats = 'YES'
   and owner not in ('SYS', 'SYSTEM')
/

SELECT DT.OWNER,
       DT.TABLE_NAME,
       ROUND ( (DELETES + UPDATES + INSERTS) / NUM_ROWS * 100) PERCENTAGE
FROM   DBA_TABLES DT, DBA_TAB_MODIFICATIONS DTM
WHERE      DT.OWNER = DTM.TABLE_OWNER
       AND DT.TABLE_NAME = DTM.TABLE_NAME
       AND NUM_ROWS > 0
       AND ROUND ( (DELETES + UPDATES + INSERTS) / NUM_ROWS * 100,2) >= 0
       AND owner not in ('SYS', 'SYSTEM')
ORDER BY 3 desc
/
