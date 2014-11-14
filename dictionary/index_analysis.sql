SET LINESIZE 300

select table_name
      ,index_name
      ,BLEVEL+1
      ,LEAF_BLOCKS
      ,DISTINCT_KEYS
      ,AVG_LEAF_BLOCKS_PER_KEY
      ,AVG_DATA_BLOCKS_PER_KEY
      ,CLUSTERING_FACTOR
from all_indexes
where table_name = 'CPM_PND_WORKLIST'
/


-- Find High Cardinality Quereis
select hash_value, object_name, cardinality, operation, options
from v$sql_plan
where operation = 'INDEX'
  and object_owner = 'CUSTPRO'
  and cardinality > 10000
order by cardinality;



analyze index CPM_PND_WORKLIST_IX2 VALIDATE STRUCTURE;

select * from index_stats;

alter index CPM_PND_WORKLIST_IX2 coalesce;

SET LINESIZE 100



hash
2093973532 CPM_PND_WORKLIST_IX2                         2797928 INDEX                          FAST FULL SCAN
 844736461 CPM_PND_WORKLIST_IX2                         2797928 INDEX                          FAST FULL SCAN


-- *****************************************************************************

2087995783	CPM_PND_TRAN_HDR_IX11	791496	INDEX	RANGE SCAN

SELECT rawtohex(address) || '_' || child_number statement_id,
  sysdate timestamp, operation, options, object_node,
  object_owner, object_name, 0 object_instance,
  optimizer,  search_columns, id, parent_id, position,
  cost, cardinality, bytes, other_tag, partition_start,
  partition_stop, partition_id, other, distribution,
  cpu_cost, io_cost, temp_space, access_predicates,
  filter_predicates
from v$sql_plan
where hash_value = 2087995783;


select sql_text
from v$sql
where hash_value = 2087995783;

analyze index CPM_PND_TRAN_HDR_IX11 VALIDATE STRUCTURE;

select * from index_stats;

SELECT * from all_indexes
where index_name = 'CPM_PND_TRAN_HDR_IX11';

SELECT * from v$segment_statistics
where object_name = 'CPM_PND_TRAN_HDR_IX11';


alter index CPM_PND_TRAN_HDR_IX11 coalesce;

alter index CPM_PND_TRAN_HDR_IX11 rebuild;