select table_name, owner, column_name 
  from all_tab_columns
  where column_name like UPPER('%&column_name%')
/
