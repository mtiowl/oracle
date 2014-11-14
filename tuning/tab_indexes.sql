set linesize 300
column column_name format a30
break on index_name

select index_name, column_name
from all_ind_columns
where table_name = UPPER('&table_name')
order by index_name, column_position
/

break on constraint_name
select c.constraint_name, cc.column_name, c.constraint_type
  from all_cons_columns cc
      ,all_constraints c
  where c.table_name = UPPER ('&table_name')
    and c.constraint_name = cc.constraint_name
    and c.table_name = cc.table_name
    and c.constraint_type <> 'C'
  order by c.constraint_type, c.constraint_name, cc.position
/