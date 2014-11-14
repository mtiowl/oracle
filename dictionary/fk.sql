set linesize 300
column column_name format a25
column parent_column format a25
break on constraint_name

select c.constraint_name, cc.column_name
      ,parent.table_name parent_table, parent_cols.column_name parent_column
from all_cons_columns cc
    ,all_constraints c
    ,all_constraints parent
    ,all_cons_columns parent_cols
where c.table_name = upper('&child_table')
  and cc.constraint_name = c.constraint_name
  and parent.constraint_name = c.r_constraint_name
  and parent.constraint_name = parent_cols.constraint_name
/
