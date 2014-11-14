ANALYZE INDEX &index_name VALIDATE STRUCTURE;

set linesize 300
col name format a30

select name, height, lf_rows, distinct_keys, rows_per_key, blks_gets_per_access, OPT_CMPR_COUNT, OPT_CMPR_PCTSAVE, used_space, pct_used
  from index_stats;

  
set linesize 100