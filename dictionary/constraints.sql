COLUMN column_name FORMAT A30

select t.table_name, t.owner, ac.constraint_name, acc.column_name, ac.constraint_type
from all_cons_columns acc
    ,all_constraints ac
    ,all_tables t
where ac.constraint_name = acc.constraint_name
  and t.table_name = acc.table_name
  and t.table_name = UPPER('&table_name')
  and ac.constraint_type <> 'C'
order by acc.table_name
/
