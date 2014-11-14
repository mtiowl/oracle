set linesize 300
set pagesize 500
clear breaks
col owner format a12
col index_name format a30
col index_size format 999,999,999.00
col index_size_mb format 999,999,999.00
ttitle center 'U n h e a l t h y   I n d e x e s' skip 1 -
  center ================================================ skip 1 -
  center '% Used less than 80% and over 100 MB in size' skip 3
break on owner skip 1
compute count of index_name on owner

select * 
  from bsts_index_statistics
  where pct_used < 80
    and index_size > 100  --over 100 MB
  order by owner, pct_used;


set linesize 100