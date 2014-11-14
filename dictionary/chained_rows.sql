col num_rows format 999,999,999,999
col chain_cnt format 999,999,999,999
col chain_pct format 999.99
col owner format a10
set linesize 300

select owner, table_name, blocks, empty_blocks, num_rows, chain_cnt, (round(chain_cnt/num_rows,4)*100) chain_pct
from all_tables
where owner not in ('SYS', 'CTXSYS', 'SYSTEM')
  and nvl(chain_cnt, 0) > 0
order by chain_pct desc
/

@chained_row_analysis
