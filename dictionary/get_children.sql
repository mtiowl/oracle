select c.constraint_name, c.table_name child_table, cc.column_name
      ,parent.table_name parent_table, parent_cols.column_name parent_column
from all_cons_columns cc
    ,all_constraints c
    ,all_constraints parent
    ,all_cons_columns parent_cols
where parent.table_name = upper('&parent_table')
  and cc.constraint_name = c.constraint_name
  and parent.constraint_name = c.r_constraint_name
  and parent.constraint_name = parent_cols.constraint_name
/
