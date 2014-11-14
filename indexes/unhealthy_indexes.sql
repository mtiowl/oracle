spool unhealthy_indexes.out

--DROP TABLE bsts_index_statistics;
/*
CREATE TABLE bsts_index_statistics 
      NOLOGGING PCTFREE 0
      AS SELECT di.owner, di.index_name, di.freelists, di.pct_free, di.logging, di.last_analyzed
               ,round(sum(ds.bytes)/1024/1024, 2) index_size_mb
               ,istat.height
               ,istat.blocks
               ,di.clustering_factor
               ,istat.lf_blks
               ,istat.br_blks
               ,istat.del_lf_rows
               ,istat.pct_used
               ,istat.blks_gets_per_access
               ,istat.distinct_keys
               ,sysdate created_date
           FROM dba_indexes di
               ,dba_segments ds
               ,index_stats istat
           WHERE di.index_name = ds.segment_name
             AND di.index_name = istat.name
             AND di.owner NOT IN ('SYS', 'SYSTEM', 'CTXSYS','DBSNMP', 'XDB','WMSYS', 'AIM_ADMINISTRATOR', 'PPLQUEST', 'OAS_PUBLIC', 'WEBSYS')
             AND 1>2
           GROUP BY di.owner, di.index_name, di.freelists, di.pct_free, di.logging, di.last_analyzed
               ,istat.height
               ,istat.blocks
               ,di.clustering_factor
               ,istat.lf_blks
               ,istat.br_blks
               ,istat.del_lf_rows
               ,istat.pct_used
               ,istat.blks_gets_per_access
               ,istat.distinct_keys;
*/          
SELECT instance_name, host_name, version FROM v$instance;

select owner, count(*)
  from dba_indexes
  where owner not in ('SYS', 'SYSTEM', 'CTXSYS','DBSNMP', 'XDB','WMSYS', 'AIM_ADMINISTRATOR', 'PPLQUEST', 'OAS_PUBLIC', 'WEBSYS')
  group by owner
  order by 2 desc;

DECLARE

  CURSOR get_indexes IS
    SELECT owner, index_name
      FROM dba_indexes
      WHERE owner NOT IN ('SYS', 'SYSTEM', 'CTXSYS','DBSNMP', 'XDB','WMSYS', 'AIM_ADMINISTRATOR', 'PPLQUEST', 'OAS_PUBLIC', 'WEBSYS')
        AND owner = 'PPLSCIS';
      
BEGIN

  FOR irec IN get_indexes LOOP
     execute immediate 'analyze index '||irec.owner||'.'||irec.index_name||' validate structure';
     
     DELETE bsts_index_statistics
       WHERE owner = irec.owner
         AND index_name = irec.index_name;
  
     INSERT INTO bsts_index_statistics
      SELECT di.owner, di.index_name, di.freelists, di.pct_free, di.logging, di.last_analyzed
          ,round(sum(ds.bytes)/1024/1024, 2) index_size_mb
          ,istat.height
          ,istat.blocks
          ,di.clustering_factor
          ,istat.lf_blks
          ,istat.br_blks
          ,istat.del_lf_rows
          ,istat.pct_used
          ,istat.blks_gets_per_access
          ,istat.distinct_keys
          ,sysdate
      FROM dba_indexes di
          ,dba_segments ds
          ,index_stats istat
      WHERE di.index_name = ds.segment_name
        AND di.index_name = istat.name
        AND di.owner NOT IN ('SYS', 'SYSTEM', 'CTXSYS','DBSNMP', 'XDB','WMSYS', 'AIM_ADMINISTRATOR', 'PPLQUEST', 'OAS_PUBLIC', 'WEBSYS')
      GROUP BY di.owner, di.index_name, di.freelists, di.pct_free, di.logging, di.last_analyzed
          ,istat.height
          ,istat.blocks
          ,di.clustering_factor
          ,istat.lf_blks
          ,istat.br_blks
          ,istat.del_lf_rows
          ,istat.pct_used
          ,istat.blks_gets_per_access
          ,istat.distinct_keys;
      
      COMMIT;
      
  END LOOP;
END;
/

spool off