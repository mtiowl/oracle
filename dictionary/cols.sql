col column_name  format a30
col num_distinct format 999999999 head 'DISTINCT'
col num_nulls    format 99999999  head 'NULLS'
col owner format a12
col avg_col_len format 990 head 'COL|LEN'
col data_type format a8 head 'DATATYPE'

break on owner
select column_name,num_distinct,num_nulls,substr(data_type,1,8) data_type,
       avg_col_len,owner
  from all_tab_columns
 where table_name=UPPER('&1')
 order by 1;
