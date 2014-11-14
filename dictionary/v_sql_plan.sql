SET HEAD OFF
SET VERIFY OFF
SET FEEDBACK OFF

DEFINE s_id = &SQL_ID

DROP TABLE dynamic_plan_table;

create TABLE dynamic_plan_table AS
  select rawtohex(address) || '_' || child_number statement_id,
         sql_id,
         sysdate timestamp, operation, options, object_node,
         object_owner, object_name, 0 object_instance,
         optimizer,  search_columns, id, parent_id, position,
         cost, cardinality, bytes, other_tag, partition_start,
         partition_stop, partition_id, other, distribution,
         cpu_cost, io_cost, temp_space, access_predicates,
         filter_predicates
    from v$sql_plan
    --where sql_id ='7zwxjfr5z1hqb' 
    where sql_id = '&S_ID';


select plan_table_output
  from TABLE( dbms_xplan.display ( 'dynamic_plan_table'
                                 , (select statement_id from dynamic_plan_table where sql_id = '&S_ID' and rownum = 1 )
                                 --, 'serial' ) )
                                 , 'ADVANCED' ) )
/

DROP TABLE dynamic_plan_table;

SET HEAD ON
SET VERIFY ON