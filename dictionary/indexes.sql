set linesize 300
column column_name format a30
break on index_name

select idx.index_name, idx.index_type, cols.column_name
      ,idx.tablespace_name
      ,GLOBAL_STATS   
      ,DOMIDX_STATUS  
      ,DOMIDX_OPSTATUS
      ,FUNCIDX_STATUS 
      ,JOIN_INDEX
      ,last_analyzed
      ,exp.column_expression
from all_ind_columns cols
    ,all_indexes idx
    ,all_ind_expressions exp
where idx.table_name = UPPER('&table_name')
  and idx.index_name = cols.index_name
  and idx.index_name = exp.index_name(+)
order by idx.index_name, cols.column_position
/
