define m_owner = &m_schema 
define m_table_name = &m_table 
define m_index_name = &m_index   

column ind_id new_value m_ind_id   

select  object_id ind_id 
  from  dba_objects 
  where owner = upper('&m_owner') 
    and object_name = upper('&m_index_name') 
    and object_type = 'INDEX' ;   
    
column col01    new_value m_col01 
column col02    new_value m_col02 
column col03    new_value m_col03 
column col04    new_value m_col04 
column col05    new_value m_col05 
column col06    new_value m_col06 
column col07    new_value m_col07 
column col08    new_value m_col08 
column col09    new_value m_col09   

select   nvl(max(decode(column_position, 1,column_name)),'null')        col01
        ,nvl(max(decode(column_position, 2,column_name)),'null')        col02
        ,         nvl(max(decode(column_position, 3,column_name)),'null')        col03
        ,         nvl(max(decode(column_position, 4,column_name)),'null')        col04
        ,         nvl(max(decode(column_position, 5,column_name)),'null')        col05
        ,         nvl(max(decode(column_position, 6,column_name)),'null')        col06
        ,         nvl(max(decode(column_position, 7,column_name)),'null')        col07
        ,         nvl(max(decode(column_position, 8,column_name)),'null')        col08
        ,         nvl(max(decode(column_position, 9,column_name)),'null')        col09 
  from  dba_ind_columns 
  where table_owner = upper('&m_owner') 
    and table_name  = upper('&m_table_name') 
    and index_name  = upper('&m_index_name') 
  order by  column_position ;   
  
break on report skip 1 
compute sum of blocks on report 
compute sum of row_ct on report   

spool index_efficiency_3   
prompt Owner &m_owner 
prompt Table &m_table_name 
prompt Index &m_index_name   
set verify off   

select         rows_per_block,         blocks
       ,         rows_per_block * blocks                     row_ct
       ,         sum(blocks) over (order by rows_per_block)  cumulative_blocks 
  from    (select rows_per_block
                 ,count(*) blocks         
             from    (select /*+ cursor_sharing_exact dynamic_sampling(0) no_monitoring no_expand index_ffs(t1, &m_index_name) noparallel_index(t1, &m_index_name) */
                             sys_op_lbid( &m_ind_id ,'L',t1.rowid) as block_id
                            ,count(*)   as rows_per_block                 
                        from   &m_owner..&m_table_name t1
                              --&m_owner..&m_table_name sample block (5) t1                 
                        where &m_col01 is not null 
                           or &m_col02 is not null                 
                           or &m_col03 is not null                 
                           or &m_col04 is not null                 
                           or &m_col05 is not null                 
                           or &m_col06 is not null                 
                           or &m_col07 is not null                 
                           or &m_col08 is not null                 
                           or &m_col09 is not null                 
                        group by sys_op_lbid( &m_ind_id ,'L',t1.rowid)                 )
              group by rows_per_block ) 
  order by  rows_per_block ;   

spool off 

