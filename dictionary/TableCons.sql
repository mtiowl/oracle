select c.constraint_name, constraint_type, cc.column_name
from all_cons_columns cc
    ,all_constraints c
where c.table_name = upper('&child_table')
  and cc.constraint_name = c.constraint_name
/
